$rgName = 'myResourceGroup'

$vmName = 'myVM'

Stop-AzVM -ResourceGroupName $rgName -Name $vmName -Force

ConvertTo-AzVMManagedDisk -ResourceGroupName $rgName -VMName $vmName