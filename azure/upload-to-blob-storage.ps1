$storageAccountName = "<your storage account name>"
$storageAccountKey = "<your storage account key>"
$containerName = "<your container name>"
$storageAccountURL = "https://" + $storageAccountName + ".blob.core.windows.net/"
$sourceFolder = "C:\Upload\"
$file1Name = "testfile1.txt"
$file2Name = "testfile2.txt"

$storageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

Write-Output "Uploading file using PowerShell..."
Write-host ""

# Upload file manually
Set-AzureStorageBlobContent -File $sourceFolder$file1Name -Container $containerName -Blob $file1Name -Context $storageContext

Get-AzureStorageBlob -Container $containerName -Context $storageContext 

Write-Output "Uploading file using AzCopy"
Write-host ""

# Upload file using AzCopy
AzCopy /Source:$sourceFolder /Dest:$storageAccountURL$containerName /DestKey:$storageAccountKey /Pattern:$file2Name

Write-Output "AzCopy Completed"
Write-host ""

#list container contents
Get-AzureStorageBlob -Container $containerName -Context $storageContext