<#
Create a New VM from a Snapshot
Ref: https://docs.microsoft.com/en-us/azure/virtual-machines/scripts/virtual-machines-windows-powershell-sample-create-vm-from-snapshot?toc=%2fpowershell%2fmodule%2ftoc.json
#>

#Provide the subscription Id
$subscriptionId = '2fbf906e-1101-4bc0-b64f-adc44e462fff'

#Provide the name of your resource group
$resourceGroupName = 'LB'

#Provide the name of the snapshot that will be used to create OS disk
$snapshotName = 'web1-snapshot'

#Provide the name of the OS disk that will be created using the snapshot
$osDiskName = 'web1_OsDisk_1_910158270e0b4a4893ba269b1301c609'

#Provide the name of an existing virtual network where virtual machine will be created
$virtualNetworkName = 'hybrid-rg'

#Provide the name of the virtual machine
$virtualMachineName = 'web1'

#Provide the size of the virtual machine
#e.g. Standard_DS3
#Get all the vm sizes in a region using below script:
#e.g. Get-AzVMSize -Location 'East US 2'
$virtualMachineSize = 'Standard_D3_v2'

#Set the context to the subscription Id where Managed Disk will be created
Select-AzSubscription -SubscriptionId $SubscriptionId

$snapshot = Get-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName

$diskConfig = New-AzDiskConfig -Location $snapshot.Location -SourceResourceId $snapshot.Id -CreateOption Copy

$disk = New-AzDisk -Disk $diskConfig -ResourceGroupName 'restore' -DiskName $osDiskName

#Initialize virtual machine configuration
$VirtualMachine = New-AzVMConfig -VMName $virtualMachineName -VMSize $virtualMachineSize

#Use the Managed Disk Resource Id to attach it to the virtual machine. Please change the OS type to linux if OS disk has linux OS
$VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -ManagedDiskId $disk.Id -CreateOption Attach -Windows

#Create a public IP for the VM
$publicIp = New-AzPublicIpAddress -Name ($VirtualMachineName.ToLower() + '_ip') -ResourceGroupName $resourceGroupName -Location $snapshot.Location -AllocationMethod Dynamic

#Get the virtual network where virtual machine will be hosted
$vnet = Get-AzVirtualNetwork -Name 'hybrid-vnet' -ResourceGroupName 'hybrid-rg'

# Create NIC in the first subnet of the virtual network
$nic = New-AzNetworkInterface -Name ($VirtualMachineName.ToLower() + '_nic') -ResourceGroupName $resourceGroupName -Location $snapshot.Location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $publicIp.Id

$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $nic.Id

New-AzVM -VM $VirtualMachine -ResourceGroupName 'restore' -Location $snapshot.Location