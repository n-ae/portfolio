<#
.SYNOPSIS
Moves a designated folder to a new location, updates a persistent environment variable,
and secures the folder by making it read-only and undeletable.

.DESCRIPTION
This script is designed to manage a specific, protected folder. It uses a user-level
environment variable ('ProtectedFolderPath') to remember the folder's last valid location.

When executed with a new path as an argument, it will:
1.  Retrieve the last known path from the environment variable.
2.  Temporarily remove protections from the old folder to allow it to be moved.
3.  Move the folder to the new specified path.
4.  Update the environment variable to store the new path.
5.  Re-apply protections to the folder at its new location, making it and its contents
    read-only and preventing the folder itself from being deleted.

Assumes the folder and environment variable are managed exclusively by this script.
If run for the first time, it will assume the folder does not exist and will create it
at the specified path.

.PARAMETER NewPath
[string] The absolute path where the folder should be moved to or created. This is a mandatory parameter.

.EXAMPLE
PS C:\> .\Move-ProtectedFolder.ps1 -NewPath "D:\SecureData\ProjectX"

This command moves the protected folder from its last known location to "D:\SecureData\ProjectX",
updates the environment variable, and re-secures the folder.

.NOTES
Author: Gemini
Version: 1.3
Requires: PowerShell 5.0 or higher.
Must be run with sufficient privileges to modify file permissions (ACLs) and user
environment variables. Running as an Administrator is recommended.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$NewPath
)

# --- Configuration ---
# The name of the environment variable used to store the folder's path.
$envVarName = "ProtectedFolderPath"

# --- Functions ---

function Set-FolderProtection {
    param (
        [string]$Path
    )
    Write-Verbose "Applying protections to '$Path'..."
    try {
        if (-not (Test-Path -Path $Path)) {
            Write-Error "Cannot apply protection. Path does not exist: $Path"
            return
        }

        # 1. Make all files within the folder read-only.
        Get-ChildItem -Path $Path -Recurse -File | ForEach-Object {
            Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $true
            Write-Verbose "Set file to read-only: $($_.FullName)"
        }

        # 2. Set the folder and its subfolders to ReadOnly and System.
        # The 'System' attribute adds a layer of protection against accidental deletion in Explorer.
        Get-ChildItem -Path $Path -Recurse -Directory | ForEach-Object {
            [System.IO.File]::SetAttributes($_.FullName, ([System.IO.FileAttributes]::ReadOnly -bor [System.IO.FileAttributes]::System))
            Write-Verbose "Set directory to ReadOnly+System: $($_.FullName)"
        }
        # Apply to the root folder as well
        [System.IO.File]::SetAttributes($Path, ([System.IO.FileAttributes]::ReadOnly -bor [System.IO.FileAttributes]::System))
        Write-Verbose "Set root directory to ReadOnly+System: $Path"


        # 3. Modify the Access Control List (ACL) to deny deletion of the folder itself.
        # This is the strongest protection against deletion.
        $acl = Get-Acl -Path $Path
        # The identity "Everyone" is used to apply this rule broadly.
        $identity = "Everyone"
        # This rule denies the 'Delete' right.
        # 'ContainerInherit' means this rule applies to the folder itself.
        $denyDeleteRule = [System.Security.AccessControl.FileSystemAccessRule]::new(
            $identity,
            [System.Security.AccessControl.FileSystemRights]::Delete,
            [System.Security.AccessControl.InheritanceFlags]::ContainerInherit,
            [System.Security.AccessControl.PropagationFlags]::None,
            [System.Security.AccessControl.AccessControlType]::Deny
        )
        $acl.AddAccessRule($denyDeleteRule)
        Set-Acl -Path $Path -AclObject $acl
        Write-Host -ForegroundColor Green "Successfully applied read-only and delete protection to '$Path'."

    }
    catch {
        Write-Error "An error occurred while setting folder protection: $_"
        # Exit the script if protection fails, as the folder is in an insecure state.
        exit 1
    }
}

function Remove-FolderProtection {
    param (
        [string]$Path
    )
    Write-Verbose "Removing protections from '$Path'..."
    try {
        if (-not (Test-Path -Path $Path)) {
            Write-Verbose "Path to unprotect does not exist, skipping: $Path"
            return
        }

        # 1. Remove the 'Deny Delete' ACL rule.
        $acl = Get-Acl -Path $Path
        $identity = "Everyone"
        $denyDeleteRule = [System.Security.AccessControl.FileSystemAccessRule]::new(
            $identity,
            [System.Security.AccessControl.FileSystemRights]::Delete,
            [System.Security.AccessControl.InheritanceFlags]::ContainerInherit,
            [System.Security.AccessControl.PropagationFlags]::None,
            [System.Security.AccessControl.AccessControlType]::Deny
        )
        $acl.RemoveAccessRule($denyDeleteRule) | Out-Null
        Set-Acl -Path $Path -AclObject $acl
        Write-Verbose "Removed 'Deny Delete' ACL rule from '$Path'."

        # 2. Remove ReadOnly and System attributes from the folder and its contents.
        # Must be done before moving.
        Get-ChildItem -Path $Path -Recurse | ForEach-Object {
            # Use the bitwise AND operator with NOT to remove the attributes.
            $attributes = [System.IO.File]::GetAttributes($_.FullName)
            $newAttributes = $attributes -band (-bnot ([System.IO.FileAttributes]::ReadOnly -bor [System.IO.FileAttributes]::System))
            [System.IO.File]::SetAttributes($_.FullName, $newAttributes)
        }
        $attributes = [System.IO.File]::GetAttributes($Path)
        $newAttributes = $attributes -band (-bnot ([System.IO.FileAttributes]::ReadOnly -bor [System.IO.FileAttributes]::System))
        [System.IO.File]::SetAttributes($Path, $newAttributes)

        Write-Host -ForegroundColor Yellow "Temporarily removed protections from '$Path'."
    }
    catch {
        Write-Error "An error occurred while removing folder protection: $_"
        # Exit the script as we cannot proceed with the move.
        exit 1
    }
}


# --- Main Logic ---

# Resolve the new path to an absolute path to avoid ambiguity.
$resolvedNewPath = Resolve-Path -Path $NewPath -ErrorAction SilentlyContinue
if (-not $resolvedNewPath) {
    Write-Error "The new path '$NewPath' is invalid or could not be resolved."
    exit 1
}

# Get the last known path from the user's environment variables.
$lastPath = [System.Environment]::GetEnvironmentVariable($envVarName, "User")

# Check if a last path exists and is valid.
if (-not ([string]::IsNullOrEmpty($lastPath)) -and (Test-Path -Path $lastPath)) {
    Write-Host "Found last known folder location: '$lastPath'"

    # Unprotect the old folder so it can be moved.
    Remove-FolderProtection -Path $lastPath

    # Move the item.
    Write-Host "Moving folder from '$lastPath' to '$resolvedNewPath'..."
    try {
        Move-Item -Path $lastPath -Destination $resolvedNewPath -Force -ErrorAction Stop
        Write-Host -ForegroundColor Green "Move successful."
    }
    catch {
        Write-Error "Failed to move folder. Error: $_"
        Write-Warning "Attempting to re-apply protection to the original folder at '$lastPath'."
        Set-FolderProtection -Path $lastPath
        exit 1
    }

}
else {
    # This handles the first run or a scenario where the old folder was manually deleted.
    Write-Host "No valid last path found. Assuming first-time setup."
    Write-Host "Creating new protected folder at '$resolvedNewPath'..."
    if (-not (Test-Path -Path $resolvedNewPath)) {
        try {
            New-Item -Path $resolvedNewPath -ItemType Directory -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Error "Failed to create directory at '$resolvedNewPath'. Error: $_"
            exit 1
        }
    } else {
        Write-Host "Directory already exists at '$resolvedNewPath'. It will be adopted and protected."
    }
}

# Update the environment variable to the new path.
# This is set at the "User" scope, so it persists between sessions for the current user.
Write-Host "Updating environment variable '$envVarName' to '$resolvedNewPath'..."
[System.Environment]::SetEnvironmentVariable($envVarName, $resolvedNewPath, "User")

# Also update the variable in the current session to ensure consistency.
# The .NET method above only affects future sessions.
# We use Get-Item/Set-Item on the env: drive, which is the most robust way.
$currentSessionValue = (Get-Item -Path "env:$envVarName" -ErrorAction SilentlyContinue).Value
if ($currentSessionValue -ne $resolvedNewPath) {
    Set-Item -Path "env:$envVarName" -Value $resolvedNewPath
    Write-Verbose "Updated environment variable for the current session."
}


# Apply protection to the folder in its new location.
Set-FolderProtection -Path $resolvedNewPath

Write-Host -ForegroundColor Cyan "Process complete. The protected folder is now at '$resolvedNewPath'."
