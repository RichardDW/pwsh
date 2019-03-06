# Load up the Azure PowerShell modules
Install-Module -Name Az -Verbose -Force

# Start VMs
Start-AzVm -Name '' -ResourceGroupName ''

# Stop VM
Get-Azvm -ResourceGroupName '' | Stop-AzVm -Force

# Resize VM
$resourceGroup = ''
$vmName = ''

Get-AzVMSize -Location 'southcentralus' | Out-GridView

Get-AzVMSize -ResourceGroupName $resourceGroup -VMName $vmName

$vm = Get-AzVM -ResourceGroupName $resourceGroup -VMName $vmName

$vm.HardwareProfile.VmSize = ''

Update-AzVM -VM $vm -ResourceGroupName $resourceGroup
