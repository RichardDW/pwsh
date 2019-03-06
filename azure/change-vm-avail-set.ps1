# Set variables
$resourceGroup = 'LB'
$vmName = 'web1'
$newAvailSetName = 'web'

# Get VM Details
$originalVM = Get-AzVm `
    -ResourceGroupName $resourceGroup `
    -Name $vmName

# Remove the original VM
Remove-AzVM -ResourceGroupName $resourceGroup -Name $vmName

# Create new availability set if it does not exist
$availSet = Get-AzAvailabilitySet `
    -ResourceGroupName $resourceGroup `
    -Name $newAvailSetName `
    -ErrorAction Ignore
if (-Not $availSet) {
    $availSet = New-AzAvailabilitySet `
        -Location $originalVM.Location `
        -Name $newAvailSetName `
        -ResourceGroupName $resourceGroup `
        -PlatformFaultDomainCount 2 `
        -PlatformUpdateDomainCount 2 `
        -Sku Aligned
}

# Create the basic configuration for the replacement VM
$newVM = New-AzVMConfig `
    -VMName $originalVM.Name `
    -VMSize $originalVM.HardwareProfile.VmSize `
    -AvailabilitySetId $availSet.Id

Set-AzVMOSDisk `
    -VM $newVM -CreateOption Attach `
    -ManagedDiskId $originalVM.StorageProfile.OsDisk.ManagedDisk.Id `
    -Name $originalVM.StorageProfile.OsDisk.Name `
    -Windows

# Add Data Disks
foreach ($disk in $originalVM.StorageProfile.DataDisks) {
    Add-AzVMDataDisk -VM $newVM `
        -Name $disk.Name `
        -ManagedDiskId $disk.ManagedDisk.Id `
        -Caching $disk.Caching `
        -Lun $disk.Lun `
        -DiskSizeInGB $disk.DiskSizeGB `
        -CreateOption Attach
}

# Add NIC(s)
foreach ($nic in $originalVM.NetworkProfile.NetworkInterfaces) {
    Add-AzVMNetworkInterface `
        -VM $newVM `
        -Id $nic.Id
}

# Recreate the VM
New-AzVM `
    -ResourceGroupName $resourceGroup `
    -Location $originalVM.Location `
    -VM $newVM `
    -DisableBginfoExtension