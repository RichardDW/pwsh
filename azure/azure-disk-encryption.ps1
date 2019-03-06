$rgName = "pluralsight"
$location = "South Central US"

Register-AzResourceProvider -ProviderNamespace "Microsoft.KeyVault"
New-AzResourceGroup -Location $location -Name $rgName

$keyVaultName = "psKeyVault7837"
New-AzKeyVault -Location $location `
    -ResourceGroupName $rgName `
    -VaultName $keyVaultName `
    -EnabledForDiskEncryption

Add-AzureKeyVaultKey -VaultName $keyVaultName `
    -Name "ADEKEY" `
    -Destination "Software"
$appName = "ADE-APP"



$securePassword = ConvertTo-SecureString -String "114rrwesNY" -AsPlainText -Force




$app = New-AzADApplication -DisplayName $appName `
    -HomePage "https://ade.ps.local" `
    -IdentifierUris "https://ade.ps/ade" `
    -Password $securePassword
New-AzADServicePrincipal -ApplicationId $app.ApplicationId

Set-AzKeyVaultAccessPolicy -VaultName $keyvaultName `
    -ServicePrincipalName $app.ApplicationId `
    -PermissionsToKeys "WrapKey" `
    -PermissionsToSecrets "Set"

$keyVault = Get-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $rgName;
$diskEncryptionKeyVaultUrl = $keyVault.VaultUri;
$keyVaultResourceId = $keyVault.ResourceId;
$keyEncryptionKeyUrl = (Get-AzureKeyVaultKey -VaultName $keyVaultName -Name ADEKEY).Key.kid

Set-AzVMDiskEncryptionExtension -ResourceGroupName $rgName `
    -VMName "managedserver" `
    -AadClientID $app.ApplicationId `
    -AadClientSecret (New-Object PSCredential "tim@timw.info", $securePassword).GetNetworkCredential().Password `
    -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl `
    -DiskEncryptionKeyVaultId $keyVaultResourceId `
    -KeyEncryptionKeyUrl $keyEncryptionKeyUrl `
    -KeyEncryptionKeyVaultId $keyVaultResourceId


Get-AzVmDiskEncryptionStatus  -ResourceGroupName $rgName -VMName "managedserver"
