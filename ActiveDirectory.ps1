# New AD User
New-ADUser "Jaap Aap" -AccountPassword (Read-Host -AsSecureString "Enter Password") -Department IT -Enabled $true
Set-ADAccountPassword 

$myADwks = Get-ADComputer -Filter * -SearchBase "OU= Workstations,OU=Machines,DC=ams,DC=securities,DC=local" |  select-object -expandproperty Name | Sort-Object

Get-ADComputer -Filter *

Get-ADReplicationFailure nz-dc-01


$gc = Get-ADForest |fl GlobalCatalogs
$gc |get-member
Get-ADForest | Select-Object -ExpandProperty Sites
Get-ADDomain
Get-ADDomain | Select-Object -ExpandProperty ReplicaDirectoryServers
# or
(Get-ADDomain).ReplicaDirectoryServers

# GET AD User properties
Get-ADUser Administrator -Properties *
Get-ADUser -Filter * -SearchBase "ou=Marketing,dc=adatum,dc=com" -SearchScope Subtree
Get-ADUser -Filter {lastlogondate -lt "January 1, 2013"}
Get-ADUser -Filter {(lastlogondate -lt "January 1, 2013") -and (department -eq "Marketing")}

Get-ADUser -Filter {lastlogondate -lt "January 1, 2013"} | Disable-ADAccount
Get-Content D:\source\olduser.txt | Disable-ADAccount

Get-ADUser -Filter {SAMAccountName -like "*wolff*"}
Get-ADUser -Filter {Name -like "*chan*"}

Get-ADUser -Filter {company -notlike "*"} | Set-ADUser -Company "A. Datum"

Get-ADReplicationSiteLink
get-aduser -Filter {SamAccountName -like "ernesto*"} |fl *
get-aduser -Filter {Enabled -eq "True"} | Measure-Object
get-help get-aduser -Fl
# Get groups a user belongs to.
Get-ADPrincipalGroupMembership -Identity franklin.staupe | select Name |sort -Property Name
# Get members of of group
Get-ADGroupMember -Identity sec-automatisering
Get-ADGroupMember -Identity "Sales Buitenland" | Select-Object Name
# Get groupmembership of a user with full path
(Get-ADUser franklin.staupe -Properties MemberOf | Select-Object MemberOf).MemberOf


# New AD Group
New-ADGroup -Name "CustomerManagement" -Path "ou=managers,de-adatum,dc=com" -GroupScope Global -GroupCategory Security

# Add user to ad group
Add-ADGroupMember CustomerManagement -Members "Jaap Aap"
  
Get-ADGroupMember -Identity SecuritisationAdministrator
Add-ADGroupMember -Identity SecuritisationAdministrator hsiaofong.chan

# Add group membership to objects
Add-ADPrincipalGroupMembership 

# Add computer account
New-ADComputer -Name WKS-001 -Path "ou=marketing,dc=adatum,dc=com" -Enabled $true
# Get Computer / User
Get-ADComputer -Identity w8-00050 -Properties Description
$MyADCOmp = Get-ADComputer -Filter * -Properties description
$MyADCOmp |where Description -like "*remko*"
$MyADCOmp |where name -like "w8-00311"

Test-ComputerSecureChannel -Verbose -Repair

# Add new OU
New-ADOrganizationalUnit -Name Sales -Path "ou=marketing,dc=adatum,dc=com" -ProtectedFromAccidentalDeletion $true

Search-ADAccount -AccountDisabled


get-help Get-ADComputer -examples

# get all AD computers and place in variable
$computers = Get-ADComputer -Filter * | Select -ExpandProperty DNSHostName
$computers.Count

$s =  Get-ADComputer -Filter 'Name -like "OPER*"' | Select -Property Name 
foreach ($item in $s)
{
Write-Host $item
Write-Host "-----------"
    
}


# see if all computers are pingable
workflow Test-WFConnection {

  param(

    [string[]]$Computers

  )

  foreach -parallel ($c in $computers) {

    Test-Connection -ComputerName $c -Count 1 -ErrorAction SilentlyContinue

  }

}


# Measure the workflow execution time
Measure-Command -Expression { Test-WFConnection -Computers $computers }




$s =  Get-ADComputer -Filter 'Name -like "OPER*"' | Select -Property Name 
foreach ($item in $s)
{
Write-Host $item
Write-Host "-----------"
    
}

# Protect AD user objects from accidental deletion
Get-ADObject -filter {(ObjectClass -eq "user")} | Set-ADObject -ProtectedFromAccidentalDeletion:$true
# Protect OU's from accidental deletion
Get-ADOrganizationalUnit -filter * | Set-ADObject -ProtectedFromAccidentalDeletion:$true


$users = Import-Csv d:\source\users.csv
foreach ($i in $users) {
    Write-Host "The first name is:" $i.firstname
    }

Import-Module D:\Scripts\GetLocalAccount.psm1

Get-OSCLocalAccount -ComputerName AUTO-506 
$la = Get-OSCLocalAccount -ComputerName AUTO-506
foreach ($acc in $la) 
{ 
    Write-Host $acc.Name
    }




# GET AD User properties
$au = Get-ADUser -Filter {SAMAccountName -like "*rossum*"}
Get-ADUser -Filter {Name -like "*chan*"}

$am = Get-ADUser -Identity richard.dewolff -Properties MemberOf
$am.MemberOf 
  
Get-ADGroupMember -Identity SecuritisationAdministrator
Add-ADGroupMember -Identity SecuritisationAdministrator hsiaofong.chan

get-help Get-ADComputer -examples

$s =  Get-ADComputer -Filter 'Name -like "OPER*"' | Select -Property Name 
foreach ($item in $s)
{
Write-Host $item
Write-Host "-----------"
    
}


# Get local users and their respective groups 
$adsi = [ADSI]"WinNT://$env:AUTO-506"
$adsi.Children | where {$_.SchemaClassName -eq 'user'} | Foreach-Object {
    $groups = $_.Groups() | Foreach-Object {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
    $_ | Select-Object @{n='UserName';e={$_.Name}},@{n='Groups';e={$groups -join ';'}}
}

Import-Module D:\Scripts\GetLocalAccount.psm1

Get-OSCLocalAccount -ComputerName AUTO-506 
$la = Get-OSCLocalAccount -ComputerName AUTO-506
foreach ($acc in $la) 
{ 
    Write-Host $acc.Name
    }




# GET AD User properties
$au = Get-ADUser -Filter {SAMAccountName -like "*rossum*"}
Get-ADUser -Filter {Name -like "*chan*"}

$am = Get-ADUser -Identity richard.dewolff -Properties MemberOf
$am.MemberOf 
  
Get-ADGroupMember -Identity SecuritisationAdministrator
Add-ADGroupMember -Identity SecuritisationAdministrator hsiaofong.chan

get-help Get-ADComputer -examples

$s =  Get-ADComputer -Filter 'Name -like "OPER*"' | Select -Property Name 
foreach ($item in $s)
{
Write-Host $item
Write-Host "-----------"
    
}


# Get local users and their respective groups 
$adsi = [ADSI]"WinNT://$env:AUTO-506"
$adsi.Children | where {$_.SchemaClassName -eq 'user'} | Foreach-Object {
    $groups = $_.Groups() | Foreach-Object {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
    $_ | Select-Object @{n='UserName';e={$_.Name}},@{n='Groups';e={$groups -join ';'}}
}

# get groups the template (existing) user is a member of:
Get-ADPrincipalGroupMembership -Identity:"CN=Milan van Hoek,OU=Gebruikers,DC=keygene,DC=local"
Get-ADPrincipalGroupMembership -Identity rwo

# save the distinguishedName for each group
# enter the existing user 
$SrcUser = 'rwo'
# store user's groups
$SrcUserGroups = Get-ADPrincipalGroupMembership -Identity $SrcUser | Select-Object -ExpandProperty distinguishedName
# add saved groups to new user
$DestUser = 'ttuu'
# loop door de groepen en voeg deze toe
foreach ( $group in $SrcUserGroups ) {
Add-ADPrincipalGroupMembership -Identity $DestUser -MemberOf "$group" -Server:"eunomia2016.keygene.local" -WhatIf
}
