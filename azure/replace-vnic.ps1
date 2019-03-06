<#
 This snippet allows to replace existing network interface of Azure RM VM with another network interface.
 Assumptions: 
  1) You successfully login to your Azure RM with Login-AzAccount cmdlet
  2) New NIC is already created
  3) All resources (VM and both NICs) are deployed into the same resource group

  Reference: https://prosharepoint.ru/replace-existing-nic-of-azure-virtual-machine-arm-with-powershell/
#>
$ResourceGroup = "myResourceGroup"
$VM = "vm1-win"
$NewNICName = "vm1-nic"

$VM = Get-AzVM -Name $VM -ResourceGroupName $ResourceGroup
$NewNIC =  Get-AzNetworkInterface -Name $NewNICName -ResourceGroupName $ResourceGroup
$VM = Add-AzVMNetworkInterface -VM $VM -Id $NewNIC.Id
$VM.NetworkProfile.NetworkInterfaces.Item(1).Primary = $true
$VM.NetworkProfile.NetworkInterfaces.RemoveAt(0)
Update-AzVM -VM $VM -ResourceGroupName $ResourceGroup