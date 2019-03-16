# This keeps me from running the whole script in case I accidentally hit F5
if (1 -eq 1) { exit }

# Connect to Azure
#$Credential = Get-Credential

Add-AzAccount

Get-CloudDrive

Get-Command -Verb get -Noun Az*network*


###############################################################
####### Resource Groups ########################

New-AzResourceGroup -name "plaz-prod1-rg" -Location "West Europe"
#Azure Shell
#az group create --name plaz-dev-rg --location "West Europe"

# Tags: 15 tag name/value pairs, no special charracters, tag name limited to 512 chars., tag value limited to 256 chars, cannot be applied to classis resources.

(Get-AzResourceGroup -Name plaz-net-rg).Tags

Set-AzResourceGroup -Name plaz-prod1-rg -Tag @{ Dept="IT"; Owner="SusanBerlin" }
Set-AzResourceGroup -Name plaz-prod1-rg -Tag @{ CostCenter="Research"; }

# If there is already a tag on a resource group you have to add additional tags as follows;
$tags = ( Get-AzResourceGroup -Name plaz-dev-rg).tags
$tags.Add("CostCenter","Research")
Set-AzResourceGroup -Name plaz-dev-rg -Tag $tags

# Azure shell
#az group show -n plaz-dev-rg --query tags
#az group update -n plaz-app1-rg --set tags.Owner=BradCocco tags.Dept=IT
 
# Clear all tags;
Set-AzEesourceGroup -Tag @{} -Name plaz-app1-rg

# Add a lock to a resource group:
New-AzResourceLock -LockName prod1NoDelete -LockLevel CanNotDelete -ResourceGroupName plaz-prod1-rg
Get-AzResourceLock �ResourceGroupName plaz-prod1-rg
$lockid = (Get-AzResourceLock �ResourceGroupName plaz-prod1-rg).LockId
Remove-AzResourceLock -LockId $lockid

# Resource Access Control (IAM)
Get-AzRoleAssignment -ResourceGroupName plaz-prod1-rg
New-AzRoleAssignment -SignInName jaap@weyland.com -RoleDefinitionName "Reader" -ResourceGroupName plaz-dev-rg

Get-AzADGroup -DisplayName "Research"
$groupid = "ee10fe3c-3577-4753-a1bc-bebcdf5498fc"
New-AzRoleAssignment -ObjectId $groupid -RoleDefinitionName "Owner" -ResourceGroupName plaz-dev-rg

# Azure CLI
# az role assignment list --resource-group plaz-dev-rg
# az lock delete --name LockGroup --resource-group plaz-app1-rg
# az role assignment create --role Owner --assignee jaap@revrichieoutlook.onmicrosoft.com --resource-group plaz-app1-rg
# az ad group list

# Policies on Resource groups

Register-AzResourceProvider -ProviderNamespace 'Microsoft.PolicyInsights'
Get-AzPolicyDefinition|Get-Member
$rg = Get-AzResourceGroup -Name '<resourceGroupName>'
$definition = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq 'Audit VMs that do not use managed disks' }
New-AzPolicyAssignment -Name 'audit-vm-manageddisks' -DisplayName 'Audit VMs without managed disks Assignment' -Scope $rg.ResourceId -PolicyDefinition $definition

Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -like '*location*' }

$rg = Get-AzResourceGroup -Name plaz-prod1-rg
$rg.ResourceId

# Move resource

$resource = Get-AzResource -ResourceGroupName plaz-net2-rg -ResourceName VNet1
Move-AzResource -DestinationResourceGroupName plaz-net-rg -ResourceId $resource.ResourceId
# Azure CLI
# $resource=(az resource show -g plaz-net-rg -n vnet1 --resource-type "Microsoft.Network/virtualNetworks" --query id --output tsv)
# az resource move --destination-group plaz-net2-rg --id $resource

Remove-AzResourceGroup -Name plaz-net-rg
# Azure CLI
# az group delete -n plaz-net2-rg





# -------------------- Resource Groups -----------------------------

####################################################################
####### Tagging ##################################
#Login-AzAccount

(Get-AzResource -ResourceName "Ubuntu1" -ResourceGroupName "RG1").Tags

(Get-AzResource -Tag @{Dept="IT"}).Name

Get-AzResource -TagName Dept

#Get a reference to an Azure resource
$r = Get-AzResource -ResourceName Ubuntu1 -ResourceGroupName RG1

#Retrieve existing resource tags, if any
$tags = (Get-AzResource -Name Ubuntu1).Tags

#Add new tags to exiting tags
$tags += @{Dept="IT"; LifeCyclePhase="Testing"}

#Write new tags to an Azure resource
Set-AzResource -ResourceId $r.Id -Tag $tags -Force

#Remove all tags
Set-AzResource -Tag @{} -ResourceId $r.id -Force

#List tags and their number of occurences
Get-AzTag

# -------------------- Tagging -----------------------


################
# Policies

$rg = Get-AzResourceGroup -Name plaz-vm1-rg

$policy_def = Get-AzPolicyDefinition | `
Where-Object { $_.Properties.DisplayName -eq "Audit VMs that do not use managed disks" }

New-AzPolicyAssignment -Name "Check for Managed Disks" -DisplayName "Check for Managed Disks" -Scope $rg.ResourceId -PolicyDefinition $policy_def

# Invoicing
$inv=Get-AzBillingInvoice -Latest
Invoke-WebRequest -Uri $inv.DownloadUrl -OutFile ('c:\temp\' + $inv.Name + '.pdf')

# Create a custom role 
# Login-AzAccount
$mySub =  Get-AzSubscription
 
$customrole = Get-AzRoleDefinition "Virtual Machine Contributor"
$customrole.Id = $null
$customrole.Name = "Virtual Machine Starter"
$customrole.Description = "Provides the ability to start a virtual machine."
$customrole.Actions.Clear()
$customrole.Actions.Add("Microsoft.Storage/*/read")
$customrole.Actions.Add("Microsoft.Network/*/read")
$customrole.Actions.Add("Microsoft.Compute/*/read")
$customrole.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
$customrole.Actions.Add("Microsoft.Authorization/*/read")
$customrole.Actions.Add("Microsoft.Resources/subscriptions/resourceGroups/read")
$customrole.Actions.Add("Microsoft.Insights/alertRules/*")
$customrole.AssignableScopes.Clear()
$customrole.AssignableScopes.Add("/subscriptions/$mySub.Id")
 
New-AzRoleDefinition -Role $customrole 

# Providers

Get-AzResourceProvider 

Get-AzProviderOperation -OperationSearchString "Microsoft.Compute/*/action"

Get-AzResourceProvider –ListAvailable | `
Where-Object{$_.ProviderNamespace -eq "Microsoft.BotService"} 

Register-AzResourceProvider -ProviderNamespace 'Microsoft.BotService'

Get-AzResourceProvider –ListAvailable | `
Where-Object{$_.ProviderNamespace -eq "Microsoft.BotService"} 

################### VM's ##########################################
#############
# restore a managed disk from a snapshot
$vm = Get-AzVM -ResourceGroupName plural-rg -Name winhost1
$disk = Get-AzDisk -ResourceGroupName plural-rg -DiskName <snapshotname>
Set-AzVMOSDisk -VM $vm -ManagedDiskId $disk.Id -Name $disk.Name
Update-AzVM -ResourceGroupName plural-rg -VM $vm





#######
# --------------------- VM's -----------------------------------

####################################################################
#Gets users from Azure Active Directory.
$Users = Get-Msoluser -all
# Assuming $users has your users
# Assuming $users.upn is the UPN, $users.licenses is licenses
ForEach ($user in $users) {
 ForEach ($license in $user.licenses) {
  $props = @{'UPN'=$user.upn
             'License' = $license}
  New-Object -Type PSObject -Prop $props
 }
}
#=======================================================
