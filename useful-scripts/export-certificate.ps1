# Define variables
$usr = [System.Environment]::GetEnvironmentVariable("USERPROFILE", [System.EnvironmentVariableTarget]::User)
$CertStoreLocation = "Cert:\LocalMachine\Root" # Example: Current User's Personal store. Change as needed.
                                           # Common locations:
                                           # Cert:\CurrentUser\My (Personal)
                                           # Cert:\LocalMachine\My (Local Computer Personal)
                                           # Cert:\LocalMachine\Root (Trusted Root Certification Authorities)

$ExportFilePath = $home + "\Downloads\zscaler-root-ca.crt" # Replace with your desired output path
$CertName = "Zscaler Root CA" # Replace with the exact name or common name you're looking for
$SearchFilter = { $_.Subject -like "*CN=$CertName*" }

try {
    # Get the certificate(s) based on the chosen filter
    $MatchingCerts = Get-ChildItem -Path $CertStoreLocation | Where-Object $SearchFilter

    if (-not $MatchingCerts) {
        Write-Error "Certificate with name '$CertName' not found in store '$CertStoreLocation'."
        exit 1
    }

    if ($MatchingCerts.Count -gt 1) {
        Write-Warning "Multiple certificates found with name '$CertName'. Exporting the first one found."
        # You might want to add logic here to:
        # - Prompt the user to choose
        # - Pick the newest one: $Cert = $MatchingCerts | Sort-Object NotBefore -Descending | Select-Object -First 1
        # - Pick the one with the latest expiry: $Cert = $MatchingCerts | Sort-Object NotAfter -Descending | Select-Object -First 1
    }

    $Cert = $MatchingCerts | Select-Object -First 1 # Select the first matching certificate

    # Export the certificate in Base64 (PEM) format
    $CertBytes = $Cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert) # DER encoded bytes
    [System.IO.File]::WriteAllBytes($ExportFilePath, $CertBytes) # Temporarily write DER

    # Convert DER to PEM (Base64)
    $DerBytes = [System.IO.File]::ReadAllBytes($ExportFilePath)
    $Base64Content = [System.Convert]::ToBase64String($DerBytes, [System.Base64FormattingOptions]::InsertLineBreaks)

    $PemContent = "-----BEGIN CERTIFICATE-----`n" + $Base64Content + "`n-----END CERTIFICATE-----`n"
    [System.IO.File]::WriteAllText($ExportFilePath, $PemContent)

    Write-Host "Certificate '$($Cert.Subject)' exported successfully to '$ExportFilePath' in PEM format."
}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    exit 1
}

