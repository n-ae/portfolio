choco install rabbitmq
choco install openssl

# Generate cacertbundle
# https://stackoverflow.com/q/8563636/7032856
$ca_name_extensionless = "cabundle"
$ca_name = "${ca_name_extensionless}.p7b"
Get-ChildItem -Path cert:\localmachine\Root | Select -Unique | Export-Certificate -FilePath cabundle.p7b -Type P7B
# https://serverfault.com/q/417140/449860
openssl pkcs7 -inform DER -print_certs -in "${ca_name}" -out "${ca_name_extensionless}.pem"
Remove-Item "${ca_name}"

## Generate server certs
$last_expiring_cert = Get-ChildItem -path cert:\LocalMachine\My | Sort-Object -Property NotAfter | Select -Unique | Select-Object -last 1
# didn't work
# $username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
# Export-PfxCertificate -Cert $last_expiring_cert -FilePath C:\myexport.pfx -ChainOption EndEntityCertOnly -NoProperties -ProtectTo $username

$password = ConvertTo-SecureString -String $(openssl rand -base64 12) -Force -AsPlainText
$server_cert_name_extensionless = "server"
$server_cert_inter_extension = "${server_cert_name_extensionless}.pfx"
Export-PfxCertificate -Cert $last_expiring_cert -FilePath "${server_cert_inter_extension}" -ChainOption EndEntityCertOnly -NoProperties -Password $password

# https://stackoverflow.com/a/28353003/7032856
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)

openssl pkcs12 -in server.pfx -out "${server_cert_name_extensionless}-keyless.pem" -nokeys -password pass:$([System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR))
$server_key_name = "${server_cert_name_extensionless}.key"
$server_key_name_inter_extension = "${server_key_name}.pem"
openssl pkcs12 -in server.pfx -out "${server_key_name_inter_extension}" -nocerts -passin pass:$([System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)) -passout pass:$([System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR))
openssl rsa -in "${server_key_name_inter_extension}" -out "${server_key_name}" -passin pass:$([System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR))

# https://stackoverflow.com/questions/28352141/convert-a-secure-string-to-plain-text#comment81060847_28353003
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

Remove-Item "${server_key_name_inter_extension}"
Remove-Item "${server_cert_inter_extension}"


function Add-Firewall-Rule{
	param ( [string]$display_name, [ValidateRange(0, 65535)][int]$port_number)
	$rule_message = "Inbound firewall rule '${display_name}' LocalPort: ${port_number}"
	$not_exists = $null -eq $(Get-NetFirewallRule -ErrorAction SilentlyContinue -DisplayName $display_name | Where-Object -Property Direction -eq "Inbound" | Get-NetFirewallPortFilter | Where-Object -Property LocalPort -eq $port_number)
	if($not_exists) {
		netsh advfirewall firewall add rule name=${display_name} dir=in action=allow protocol=TCP localport=${port_number}
		echo "Created ${rule_message}"
	}
	else {
		echo "Has not created ${rule_message} as it already exists!"
	}
}

# access the management ui remotely
Add-Firewall-Rule "RabbitMQ Management" 15671
# access AMQP remotely
Add-Firewall-Rule "RabbitMQ AMQP" 5671
