$UsGroup = "ri.gpo.W10XXTestSecGrpDummyX.us"
$GsGroup = "eu.gpo.W10XXTestSecGrpDummyX.gs"
$USdomain = "RABONET"
$GSDomain = "RABONETEU"

Dev-Global-W10ScriptHardeningExclusion

# USe following command to get a DC per domain
$DC_NET    = [string](Get-ADDomainController -Discover -DomainName rabonet.com).HostName
$DC_NET_EU = [string](Get-ADDomainController -Discover -DomainName eu.rabonet.com).HostName
$DC_NET_AM = [string](Get-ADDomainController -Discover -DomainName am.rabonet.com).HostName
$DC_NET_AP = [string](Get-ADDomainController -Discover -DomainName ap.rabonet.com).HostName
$DC_NET_OC = [string](Get-ADDomainController -Discover -DomainName oc.rabonet.com).HostName


$gsdomdrp = "$GSDomain$GsGroup"

Add-ADGroupMember -Identity $UsGroup -Members $GSDomain\$GsGroup -Server $DC_NET  # NoGo

$MyGSGroup = Get-ADGroup $GsGroup -Server $DC_NET_EU

Add-ADGroupMember -Identity $UsGroup -Members $MyGSGroup -Server $DC_NET 


$AdPath = "AD:\CN=eu.gpo.W10XXTestSecGrpDummyX.gs,OU=Application,OU=Groups,DC=eu,DC=rabonet,DC=com"
$acl = Get-Acl -Path $AdPath


#==============================================================



$group = Get-ADGroup -Identity 'eu.gpo.W10XXTestSecGrpDummyX.gs' -Server $DC_NET_EU
$manager = Get-ADGroup -Identity 'eu-role-Windows 10 Production Admins' -Server $DC_NET_EU
$NTPrincipal = New-Object System.Security.Principal.NTAccount $manager.samAccountName
$managerGUID = $manager.ObjectGUID | Select-Object Guid -ExpandProperty Guid
$objectGUID = New-Object GUID $managerGUID
$acl = Get-ACL "AD:$($group.distinguishedName)"
$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $NTPrincipal,'WriteProperty','Allow',$objectGUID
$acl.AddAccessRule($ace)
Set-ACL -AclObject $acl -Path "AD:$($group.distinguishedName)"



# Testing for EU

$psDriveName = 'AD'
$psDrivePath = $psDriveName + ':'

If (Test-Path -Path $psDrivePath) { Write-Host "PS Drive exists already" -ForegroundColor Red}
Else { New-PSDrive -Name $psDriveName -PSProvider ActiveDirectory -Server $DC_NET_AM -root "//RootDSE/" }


$group = Get-ADGroup -Identity 'eu.gpo.W10XXTestSecGrpDummyX.gs' -Server $DC_NET_EU
$manager = Get-ADGroup -Identity 'eu-role-Windows 10 Production Admins' -Server $DC_NET_EU
$NTPrincipal = New-Object System.Security.Principal.NTAccount $manager.samAccountName
$managerGUID = $manager.ObjectGUID | Select-Object Guid -ExpandProperty Guid
$objectGUID = New-Object GUID $managerGUID
$acl = Get-ACL "AD:$($group.distinguishedName)"
$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $NTPrincipal,'WriteProperty','Allow',$objectGUID
$acl.AddAccessRule($ace)
Set-ACL -AclObject $acl -Path "AD:$($group.distinguishedName)"



#  TEST FOR AM REGION , SETTING ACL FOR NON-EU DOMAIN
$gpoFullName = "XXX-Global-W10XXTestSecGrpDummyX"
$Description = "Grants access to GPO: $gpoFullName"


$secgrp = 'am.gpo.W10XXTestSecGrpDummyX.gs'
$mgrgrp = 'am.mgt.WorkstationSupport.gs'
$Path = 'OU=Application,OU=Groups,DC=am,DC=rabonet,DC=com'

# Create Global Security Group
Write-Host "Now creating Security Group $secGroupName"  -ForegroundColor Magenta
New-ADGroup -Name $secgrp -GroupCategory Security -GroupScope Global -Path $Path -Description $Description -Server $DC_NET_AM -ManagedBy $mgrgrp

$psDriveName = 'AD_AM'
If (Get-PSDrive -Name $psDriveName) { Write-Host "PS Drive exists already" -ForegroundColor Red}
Else { New-PSDrive -Name $psDriveName -PSProvider ActiveDirectory -Server $DC_NET_AM -root "//RootDSE/" }
$psDriveName = 'AD_AM:'
# SET ACL Rights
$group = Get-ADGroup -Identity $secgrp -Server $DC_NET_AM
$manager = Get-ADGroup -Identity $mgrgrp -Server $DC_NET_AM
$NTPrincipal = New-Object System.Security.Principal.NTAccount $manager.samAccountName
$managerGUID = $manager.ObjectGUID | Select-Object Guid -ExpandProperty Guid
$objectGUID = New-Object GUID $managerGUID
$acl = Get-ACL "${$psDriveName}:$($group.distinguishedName)"
$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $NTPrincipal,'WriteProperty','Allow',$objectGUID
$acl.AddAccessRule($ace)
Set-ACL -AclObject $acl -Path "$psDriveName$($group.distinguishedName)"

Get-PSDrive
Remove-PSDrive -Name $psDriveName




