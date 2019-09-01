# Create a self signed Code Signing certificate
New-SelfSignedCertificate -CertStoreLocation cert:\currentuser\my `
-Subject "CN=Wolco Code Signing" `
-FriendlyName "Wolco CSC" `
-KeyAlgorithm RSA `
-KeyLength 2048 `
-DnsName "WolcoCSC" `
-Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `
-KeyExportPolicy Exportable `
-KeyUsage DigitalSignature `
-Type CodeSigningCert

<# 
Microsoft Software Key Storage Provider
Microsoft Smart Card Key Storage Provider
Microsoft Platform Crypto Provider
Microsoft Strong Cryptographic Provider
Microsoft Enhanced Cryptographic Provider v1.0
Microsoft Enhanced RSA and AES Cryptographic Provider
Microsoft Base Cryptographic Provider v1.0
#>

New-SelfSignedCertificate -DnsName "www.wolco.com", "www.contoso.com" -CertStoreLocation "cert:\currentuser\My"

New-SelfSignedCertificate -Type Custom -Subject "E=patti.fuller@contoso.com,CN=Patti Fuller" `
-TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.4","2.5.29.17={text}email=patti.fuller@contoso.com&upn=pattifuller@contoso.com") `
-KeyAlgorithm RSA `
-KeyLength 2048 `
-SmimeCapabilities `
-CertStoreLocation "Cert:\CurrentUser\My"


Set-Location -Path "cert:\CurrentUser\My"
# Path is the Thumbprint of the certificate
$OldCert = (Get-ChildItem -Path 905C084E7D4A717777CA5AEFA3E268C7CC8A305E)
New-SelfSignedCertificate -CloneCert $OldCert



$CodeSigningCert = Get-ChildItem Cert:\CurrentUser\My\ -CodeSigningCert 
Set-AuthenticodeSignature –Certificate $CodeSigningCert `
–TimeStampServer http://timestamp.verisign.com/scripts/timstamp.dll `
-FilePath .\<scriptname>.ps1 `
-IncludeChain notroot


# Get digital signature for each running process
Get-Process | foreach {$DigiCert = try {Get-AuthenticodeSignature -FilePath $_.path} catch { } ; $_ |
Select-Object name,ID,path,Description | Add-Member "NoteProperty" CertStatus $( If($DigiCert) {$DigiCert.Status} else {"Access Denied"} )  -PassThru |
Add-Member "Noteproperty" Subject $($DigiCert.SignerCertificate.Subject) -PassThru |
Add-Member "NoteProperty" ThumbPrint $($DigiCert.SignerCertificate.Thumbprint) -PassThru } | ft
#
Get-ChildItem C:\ -Include @("*.exe","*.dll") -R -File | foreach {$DigiCert = try {Get-AuthenticodeSignature -FilePath $_.FullName} catch { } ; $_ |
Select-Object name,FullName | Add-Member "Noteproperty" FileDescription $_.VersionInfo.FileDescription -PassThru |
Add-Member "NoteProperty" CertStatus $( If($DigiCert.Status -eq "UnknownError") {"NOT FOUND"} else {$DigiCert.Status} )  -PassThru |
Add-Member "Noteproperty" Subject $($DigiCert.SignerCertificate.Subject) -PassThru |
Add-Member "NoteProperty" ThumbPrint $($DigiCert.SignerCertificate.Thumbprint) -PassThru } | ft

#"certificateName": "RaboCSC",
#		"certificateLocation": "cert:\\LocalMachine\\Root",

#Change to the location of the personal certificates
Set-Location Cert:\CurrentUser\My
 
#Change to the location of the local machine certificates
Set-Location Cert:\LocalMachine\My
 
#Get the installed certificates in that location
Get-ChildItem | Format-Table Subject, FriendlyName, Thumbprint -AutoSize 
 
#Get the installed certificates from a remote machine
$Srv = "SERVER-HOSTNAME"
$Certs = Invoke-Command -Computername $Srv -Scriptblock {Get-ChildItem "Cert:\LocalMachine\My"}


###############################

New-SelfSignedCertificate -CertStoreLocation cert:\currentuser\my `
-Subject "CN=Wolco CSC" `
-KeyAlgorithm RSA `
-KeyLength 2048 `
-DnsName "WolcoCSC" `
-Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `
-KeyExportPolicy Exportable `
-KeyUsage DigitalSignature `
-Type CodeSigningCert

# After creating certificate, copy to 'Trusted Root CA' and into 'Trusted Publishers'

Get-ChildItem cert:\CurrentUser\my -codesigning

$cert = @(Get-ChildItem cert:\CurrentUser\My -DNSname 'WolcoCSC' -CodeSigning)[0] 
Set-AuthenticodeSignature C:\temp\Test-Sign.ps1 $cer
Get-AuthenticodeSignature C:\temp\Test-Sign.ps1


#########################################################
#requires -runasadministrator 

# Paolo Frigo, https://www.scriptinglibray.com

# This scripts generates a self-signed certificate for CodeSigning and exports to a PFX Format

#SETTINGS
$CertificateName = "Wolco Code Sign"
$OutPutPFXFilePath = "c:\temp\Wolco_Code_sign_cert.pfx"
$MyStrongPassword = ConvertTo-SecureString -String "SvCECdIjcZ<XB0G2VyJw[G0<" -Force -AsPlainText 

# Create Self signed certificate in Current User\Personal\Certificates
# and export pfx certificate
New-SelfSignedCertificate `
-Subject "CN=Wolco Code Signing" `
-FriendlyName "Wolco CSC" `
-KeyAlgorithm RSA `
-KeyLength 2048 `
-DnsName "WolcoCSC" `
-Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `
-KeyExportPolicy Exportable `
-KeyUsage DigitalSignature `
-Type CodeSigningCert |
Export-PfxCertificate -FilePath $OutPutPFXFilePath -password $MyStrongPassword 

Write-Output "PFX Certificate `"$CertificateName`" exported to: $OutPutPFXFilePath"

# Optional: Create a powershell script to be signed or use existing script
set-content -value "get-date" -path "c:\temp\ToBeSigned.ps1"
Get-Content c:\temp\ToBeSigned.ps1

$MyCertFromPfx = Get-PfxCertificate -FilePath "c:\temp\Wolco_Code_sign_cert.pfx"
# Enter password
#
# Sign script with pfx
Set-AuthenticodeSignature -PSPath c:\temp\ToBeSigned.ps1 -Certificate $MyCertFromPfx
# Results in a Status: UnknownError because self-signed PFX still gas to be imported

# Script is signed but when running still results in error because of failing root chain
# Fixed below by importing
Get-Content c:\temp\ToBeSigned.ps1

$myPfx = "c:\temp\Wolco_Code_sign_cert.pfx"

#How to import your Self signed PFX # Needs to run as Administrator!!!
#Personal
Import-PfxCertificate -FilePath $myPfx -CertStoreLocation "cert:\LocalMachine\My" -Password $MyStrongPassword
#TrustedPublisher
Import-PfxCertificate -FilePath $myPfx -CertStoreLocation "cert:\LocalMachine\Root" -Password $MyStrongPassword 
#Root
Import-PfxCertificate -FilePath $myPfx -CertStoreLocation "cert:\LocalMachine\TrustedPublisher" -Password $MyStrongPassword


# Sign more scripts
 get-childitem *ps1 | Set-AuthenticodeSignature -Certificate $MyCertFromPfx


