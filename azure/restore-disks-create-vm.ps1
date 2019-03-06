<# Restore managed disks from backup and create a new VM
Ref: https://docs.microsoft.com/en-us/azure/backup/backup-azure-vms-automation#restore-an-azure-vm
#>

$namedContainer = Get-AzRecoveryServicesBackupContainer  -ContainerType "AzureVM" -Status "Registered" -FriendlyName "V2VM"

$backupitem = Get-AzRecoveryServicesBackupItem -Container $namedContainer  -WorkloadType "AzureVM"

$startDate = (Get-Date).AddDays(-7)

$endDate = Get-Date

$rp = Get-AzRecoveryServicesBackupRecoveryPoint -Item $backupitem -StartDate $startdate.ToUniversalTime() -EndDate $enddate.ToUniversalTime()

$rp[0]

$restorejob = Restore-AzRecoveryServicesBackupItem -RecoveryPoint $rp[0] -StorageAccountName "DestAccount" -StorageAccountResourceGroupName "DestRG"

$restorejob

Wait-AzRecoveryServicesBackupJob -Job $restorejob -Timeout 4320

$restorejob = Get-AzRecoveryServicesBackupJob -Job $restorejob

$details = Get-AzRecoveryServicesBackupJobDetails -Job $restorejob

$properties = $details.properties

$storageAccountName = $properties["Target Storage Account Name"]

$containerName = $properties["Config Blob Container Name"]

$blobName = $properties["Config Blob Name"]

Set-AzCurrentStorageAccount -Name $storageaccountname -ResourceGroupName "testvault"

$destination_path = "C:\vmconfig.json"

Get-AzureStorageBlobContent -Container $containerName -Blob $blobName -Destination $destination_path

$obj = ((Get-Content -Path $destination_path -Raw -Encoding Unicode)).TrimEnd([char]0x00) | ConvertFrom-Json

$vm = New-AzVMConfig -VMSize $obj.'properties.hardwareProfile'.vmSize -VMName "testrestore"

$storageType = "StandardLRS"

$osDiskName = $vm.Name + "_osdisk"

$osVhdUri = $obj.'properties.storageProfile'.osDisk.vhd.uri

$diskConfig = New-AzDiskConfig -AccountType $storageType -Location "West US" -CreateOption Import -SourceUri $osVhdUri

$osDisk = New-AzDisk -DiskName $osDiskName -Disk $diskConfig -ResourceGroupName "test"

Set-AzVMOSDisk -VM $vm -ManagedDiskId $osDisk.Id -CreateOption "Attach" -Windows

foreach ($dd in $obj.'properties.storageProfile'.dataDisks) {
    $dataDiskName = $vm.Name + $dd.name ;
    $dataVhdUri = $dd.vhd.uri ;
    $dataDiskConfig = New-AzDiskConfig -AccountType $storageType -Location "West US" -CreateOption Import -SourceUri $dataVhdUri ;
    $dataDisk2 = New-AzDisk -DiskName $dataDiskName -Disk $dataDiskConfig -ResourceGroupName "test" ;
    Add-AzVMDataDisk -VM $vm -Name $dataDiskName -ManagedDiskId $dataDisk2.Id -Lun $dd.Lun -CreateOption "Attach"
}

$nicName = "p1234"

$pip = New-AzPublicIpAddress -Name $nicName -ResourceGroupName "test" -Location "WestUS" -AllocationMethod Dynamic

$vnet = Get-AzVirtualNetwork -Name "testvNET" -ResourceGroupName "test"

$subnetindex = 0

$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName "test" -Location "WestUS" -SubnetId $vnet.Subnets[$subnetindex].Id -PublicIpAddressId $pip.Id

$vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id

New-AzVM -ResourceGroupName "test" -Location "WestUS" -VM $vm