<#
.SYNOPSIS
 This script creates AD security groups to be used with GPO security filtering
.DESCRIPTION
 This script creates security groups, to be used in GPO Filtering
 It will create a Universal Security Group with several Global Security Groups as member
 Which groups are created depends on the template file used (this is a CSV file)
 Additionally it will set ACL rights on the Global Security Groups for management
.PARAMETER <gpoFullName> This is a mandatory parameter
 Use this parameter to give the full GPO name to be used in the description of the Security Group
 Use the format XXX-XXXXX-XXXXXXXXX. The last part will be used as GPOCleanName, ie the name to be used for the Security Groups
.PARAMETER <gpoCleanName>
 Use this parameter to give the name to be used for the Security Group. Name is without the prefix, like eu.gpo. and without the suffix of .us/.gs/.ls
.PARAMETER <Description>
 Use this parameter for the description field to be used in the AD Security Group
 If not entered the default will be used; Grants access to GPO: 'gpoFullName'
.PARAMETER <csv> This is a mandatory parameter
 This is the path to the CSV file, which contains the template to be used for the creation of the security groups
.EXAMPLE
 Create-GPOSecGrp -gpoFullName XXX-Global-W10TestGPO -gpoCleanName Windows10TestGPO -Description "Used for exception in Edge settings" -csv "\path\to\csvfile.csv"
.EXAMPLE
 Create-GPOSecGrp -gpoFullName XXX-Global-W10TestGPO -csv "\path\to\csvfile.csv"
This will create Security Groups with a name of xx.gpo.W10TestGPO.xx and the default description of: Grants access to GPO: W10TestGPO

#>


# Parameters

# Options for the New-ADGroup
# -Name ri.gpo.W10ScriptHardeningExclude.us
# -Name eu.gpo.W10ScriptHardeningExclude.gs
# -Name eu.gpo.W10ScriptHardeningExclude.ls # Not member of .us group

# -GroupCategory Security
# -GroupScope Universal,Global,DomainLocal
## -DisplayName "RODC Administrators"
# -Description "Grants access to GPO: $GPO"
# -Path "OU=Application,OU=Groups,DC=rabonet,DC=com"
# -Path "OU=Application,OU=Groups,DC=eu,DC=rabonet,DC=com"

# Attributes
# cn = eu.gpo.W10ScriptHardeningPilot.gs
# description = Grant Access to xxx-Global-W10ScriptHardeningPilot
# distinguishedName = CN=eu.gpo.W10ScriptHardeningPilot.gs,OU=Application,OU=Groups,DC=eu,DC=rabonet,DC=com
# member = multi-valued (name, Container, Distinguished Name/ SID)
# name = eu.gpo.W10ScriptHardeningPilot.gs
# sAMAccountName = eu.gpo.W10ScriptHardeningPilot.gs

# Canonical name of object: eu.rabonet.com/Groups/Application/eu.gpo.W10ScriptHardeningPilot.gs


Param(
  [Parameter(Mandatory=$true)]
  [string]$gpoFullName,
  [string]$gpoCleanName,
  [string]$Description,
  [Parameter(Mandatory=$true)]
  [string]$csv
    # add GPO Clean Name
)

# +++++++++ Comment out following block when running from command line ++++++++++++
$gpoFullName = "XXX-Global-W10XXTestSecGrpDummyX"
$Description = "Grants access to GPO: $gpoFullName"
# Read in the template for creating AD Security groups
# Test file
$csv = "C:\Temp\SecGroupTemplateTest.csv"
# Prod file BASIC
#$csv = "C:\Temp\SecGroupTemplateBasic.csv"
# Prod file EXTENDED
#$csv = "C:\Temp\SecGroupTemplateExt.csv"
#  ------ Comment out following block when running from command line --------------

# If gpoCleanName not entered extract from gpoFullName
If ($gpoCleanName -eq "") {
  $gpoCleanName = $gpoFullName.Split("-")[-1]
}

# if Description is not entered use default
If ($Description -eq "") {
  $Description = "Grants access to GPO: $gpoFullName"
}

# Test if cvs file exists
If (-Not (Test-Path -Path $csv)) {
  Write-Error -Message "Path to CSV file not found, try again"
  Exit
}

#Process CSV
$Template = Import-Csv -Path $csv -Delimiter ";"


# List of DC's per domain
#$DC_NET    = "BSTS111035.rabonet.com"
#$DC_NET_EU = "BSTS111031.eu.rabonet.com"
#$DC_NET_AM = "BXTS111134.am.rabonet.com"
#$DC_NET_AP = "BXTS111132.ap.rabonet.com"
#$DC_NET_OC = "BXTS111133.oc.rabonet.com"

# Use following command to get a DC per domain
$DC_NET    = [string](Get-ADDomainController -Discover -DomainName rabonet.com).HostName
$DC_NET_EU = [string](Get-ADDomainController -Discover -DomainName eu.rabonet.com).HostName
$DC_NET_AM = [string](Get-ADDomainController -Discover -DomainName am.rabonet.com).HostName
$DC_NET_AP = [string](Get-ADDomainController -Discover -DomainName ap.rabonet.com).HostName
$DC_NET_OC = [string](Get-ADDomainController -Discover -DomainName oc.rabonet.com).HostName


# Set Security Group clean name
function Set-SecGrpCleanName {


}# function Set-SecGrpCleanName


# Determine the Universal Security Group
function Get-UniversalGroup {

}# function Get-UniversalGroup


# Determine which AD Server to use
function Get-ServerAD ([string]$domain) {
  $serverAD = Switch ($domain)
   {
    rabonet.com { $DC_NET }
    eu.rabonet.com { $DC_NET_EU }
    am.rabonet.com { $DC_NET_AM }
    ap.rabonet.com { $DC_NET_AP }
    oc.rabonet.com { $DC_NET_OC }
   }# switch
   return $serverAD

}# function Get-ServerAD


#Create the Security groups
#
function Create-SecGroup {

  Write-Host "Starting with creation of Security Groups from Template"
  foreach ($secgrp in $Template) {

   #Write-Host $secgrp.Groups
   # Set Group Name for parameter Name
   $secGroupName = $secgrp.Groups -replace "\[GPO_CLEAN_NAME\]","$gpoCleanName"
   Write-Host "Processing for $secGroupName"
   #Write-Host $secgrp.Domain

   # Set DC for specific domain for parameter Server
   $AdServer = Get-ServerAD ($secgrp.Domain)
   Write-Host "DC to be used is: $AdServer"

   # Set GroupScope type for parameter GroupScope
   $grpScopeName = $secGroupName.Split(".")[-1]
   #Write-Host $grpScopeName
   $grpScope = Switch ($grpScopeName)
   {
     us { 'Universal' }
     gs { 'Global' }
     ls { 'DomainLocal' }
   }# switch
   Write-Host "Group scope to be used: $grpScope"

   # Get the Path for the group creation
   $path = $secgrp.LDAP
   Write-Host "LDAP path to be used: $path"

   # Get ManagedBy parameter
   $ManagedBy = $secgrp.Delegation
   Write-Host "Delegation to be used: $ManagedBy"
   Write-Host "Description to be used: $Description"
   #Write-Host "End of Loop"-ForegroundColor Cyan

   # Create the AD-Group
   If ($ManagedBy -eq "") {
     Write-Host "Now creating Security Group $secGroupName" -ForegroundColor Magenta
     New-ADGroup -Name $secGroupName -GroupCategory Security -GroupScope $grpScope -Path $Path -Description $Description -Server $AdServer
   }
   Else {
     Write-Host "Now creating Security Group $secGroupName"  -ForegroundColor Magenta
     New-ADGroup -Name $secGroupName -GroupCategory Security -GroupScope $grpScope -Path $Path -Description $Description -Server $AdServer -ManagedBy $ManagedBy
   }

  }# foreach
}# function Create-SecGroup


#Add AD Security groups to other AD Group
#
function Add-SecGrpMember {

  Write-Host "Starting with adding Global groups to the Universal group"
  # Get Security Group Name of the Universal Security group (.us group) for parameter Identity
  # If Group ends with .us it is the universal group

  foreach ($secgrp in $Template) {

    #Write-Host ($secgrp.Groups).Split(".")[-1]
    If (($secgrp.Groups).Split(".")[-1] -eq "us") {
      $secGroupUniversal = $secgrp.Groups -replace "\[GPO_CLEAN_NAME\]","$gpoCleanName"

    Write-Host "Universal Group found: $secGroupUniversal" -ForegroundColor Yellow
    break
    }# If
  }# foreach

  foreach ($secgrp in $Template) {

    # If MemberOff is empty, skip to next
    If ($secgrp.MemberOff -eq ""){continue}
    # Get the global security group to be added to the universal security group
    $secGroupName = $secgrp.Groups -replace "\[GPO_CLEAN_NAME\]","$gpoCleanName"

    Write-Host "Universal group: $secGroupUniversal with member global sec group: $secGroupName" -ForegroundColor Yellow

    # Get the DC to be used for collection of global security group properties
    $AdServer = Get-ServerAD ($secgrp.Domain)
    Write-Host "DC to be used is: $AdServer"

    # Get the properties of the Global Security Group
    $MyGSGroup = Get-ADGroup $secGroupName -Server $AdServer

    # Add the Global security group as a member to the Universal Security group
    Write-Host "Now adding Global Group $MyGSGroup to Universal Group $secGroupUniversal" -ForegroundColor Cyan
    Write-Host "Using server $DC_NET"  -ForegroundColor Cyan
    Add-ADGroupMember -Identity $secGroupUniversal -Members $MyGSGroup -Server $DC_NET


    #$LDAP = $secgrp.LDAP
    #Full LDAP NAME of Group
    #$secGroupName + secgrp.LDAP
    #$FullLDAP = "CN=$secGroupName,$LDAP"

  }# foreach
}# function Add-SecGrpMember


function Set-DelegationRights {

  Write-Host "Starting with Setting Delegation Rights"-ForegroundColor White
  foreach ($secgrp in $Template) {

  # If MemberOff is empty, skip to next
  If ($secgrp.Delegation -eq ""){continue}
  # get the Security group
  $secGroupName = $secgrp.Groups -replace "\[GPO_CLEAN_NAME\]","$gpoCleanName"
  $secManagedBy = $secgrp.Delegation
  # Determine DC to be used.
  $AdServer = Get-ServerAD ($secgrp.Domain)
  Write-Host "DC to be used is: $AdServer"

  # Create variable for PS Drive to be created
  $psDriveName = Switch ($secgrp.Domain)
    {
      eu.rabonet.com { 'AD_EU' }
      am.rabonet.com { 'AD_AM' }
      ap.rabonet.com { 'AD_AP' }
      oc.rabonet.com { 'AD_OC' }
    }# switch

  Write-Host "PsDrive to be created is: $psDriveName"
  # Create PSDrive Path name variable
  $psDrivePath = $psDriveName + ':'

  If (Test-Path -Path $psDrivePath) { Write-Host "PS Drive exists already"}
  Else { New-PSDrive -Name $psDriveName -PSProvider ActiveDirectory -Server $AdServer -root "//RootDSE/" }

  Write-Host "Now setting ACL on $secGroupName for Management group: $secManagedBy"
  $group = Get-ADGroup -Identity $secGroupName -Server $AdServer
  $manager = Get-ADGroup -Identity $secManagedBy -Server $AdServer
  $NTPrincipal = New-Object System.Security.Principal.NTAccount $manager.samAccountName
  $managerGUID = $manager.ObjectGUID | Select-Object Guid -ExpandProperty Guid
  $objectGUID = New-Object GUID $managerGUID
  $acl = Get-ACL "$psDrivePath$($group.distinguishedName)"
  $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $NTPrincipal,'WriteProperty','Allow',$objectGUID
  $acl.AddAccessRule($ace)
  Set-ACL -AclObject $acl -Path "$psDrivePath$($group.distinguishedName)"
  Write-Host "Done with setting ACL"

  }# foreach
}# function Set-DelegationRights


function Main {
  # Create the security groups
  Create-SecGroup
  # Sleep a bit for AD Synchro
  Write-Host "Now sleeping for 90 seconds for AD Warp signature to enter Enterprise wormhole" -ForegroundColor DarkYellow
  Start-Sleep -Seconds 90
  # Add (make member) the global security groups to the universal group
  Add-SecGrpMember
  # Set the ManagedBy Rights
  Set-DelegationRights

}# function Main

Main


