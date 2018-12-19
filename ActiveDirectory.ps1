# New AD User
New-ADUser "Jaap Aap" -AccountPassword (Read-Host -AsSecureString "Enter Password") -Department IT -Enabled $true
Set-ADAccountPassword 

$myADwks = Get-ADComputer -Filter * -SearchBase "OU= Workstations,OU=Machines,DC=ams,DC=securities,DC=local" |  select-object -expandproperty Name | Sort-Object

Get-ADComputer -Filter *

Get-ADReplicationFailure mydc-01


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
Get-ADUser -Filter {lastlogondate -lt "January 1, 2018"}
Get-ADUser -Filter {(lastlogondate -lt "January 1, 2018") -and (department -eq "Marketing")}

Get-ADUser -Filter {lastlogondate -lt "January 1, 2018"} | Disable-ADAccount
Get-Content D:\source\olduser.txt | Disable-ADAccount

Get-ADUser -Filter {SAMAccountName -like "*meisterb*"}
Get-ADUser -Filter {Name -like "*chan*"}

Get-ADUser -Filter {company -notlike "*"} | Set-ADUser -Company "A. Datum"

Get-ADReplicationSiteLink
get-aduser -Filter {SamAccountName -like "ernesto*"} |fl *
get-aduser -Filter {Enabled -eq "True"} | Measure-Object
get-help get-aduser -Fl
# Get groups a user belongs to.
Get-ADPrincipalGroupMembership -Identity franklin.staupe | select Name |sort -Property Name
# Get members of of group
Get-ADGroupMember -Identity Sales Reps
Get-ADGroupMember -Identity "Sales Managers" | Select-Object Name
# Get groupmembership of a user with full path
(Get-ADUser franklin.staupe -Properties MemberOf | Select-Object MemberOf).MemberOf


# New AD Group
New-ADGroup -Name "CustomerManagement" -Path "ou=managers,de-adatum,dc=com" -GroupScope Global -GroupCategory Security

# Add user to ad group
Add-ADGroupMember CustomerManagement -Members "Jaap Aap"
  
Get-ADGroupMember -Identity SecuritisationAdministrator
Add-ADGroupMember -Identity SecuritisationAdministrator chin.chan

# Add group membership to objects
Add-ADPrincipalGroupMembership 

# Add computer account
New-ADComputer -Name WKS-001 -Path "ou=marketing,dc=adatum,dc=com" -Enabled $true
# Get Computer / User
Get-ADComputer -Identity w8-00050 -Properties Description
$MyADCOmp = Get-ADComputer -Filter * -Properties description
$MyADCOmp |where Description -like "*joep*"
$MyADCOmp |where name -like "PC-666"

Test-ComputerSecureChannel -Verbose -Repair

# Add new OU
New-ADOrganizationalUnit -Name Sales -Path "ou=marketing,dc=adatum,dc=com" -ProtectedFromAccidentalDeletion $true

Search-ADAccount -AccountDisabled


get-help Get-ADComputer -examples

# get all AD computers and place in variable
$computers = Get-ADComputer -Filter * | Select -ExpandProperty DNSHostName
$computers.Count

$s =  Get-ADComputer -Filter 'Name -like "PC-4*"' | Select -Property Name 
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

Get-OSCLocalAccount -ComputerName PC-506 
$la = Get-OSCLocalAccount -ComputerName PC-506
foreach ($acc in $la) 
{ 
    Write-Host $acc.Name
    }




# GET AD User properties
$au = Get-ADUser -Filter {SAMAccountName -like "*rosco*"}
Get-ADUser -Filter {Name -like "*chan*"}

$am = Get-ADUser -Identity richie.meisterburger -Properties MemberOf
$am.MemberOf 
  
Get-ADGroupMember -Identity SecuritisationAdministrator
Add-ADGroupMember -Identity SecuritisationAdministrator chin.chan

get-help Get-ADComputer -examples

$s =  Get-ADComputer -Filter 'Name -like "PC-*"' | Select -Property Name 
foreach ($item in $s)
{
Write-Host $item
Write-Host "-----------"
    
}


# Get local users and their respective groups 
$adsi = [ADSI]"WinNT://$env:PC-506"
$adsi.Children | where {$_.SchemaClassName -eq 'user'} | Foreach-Object {
    $groups = $_.Groups() | Foreach-Object {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
    $_ | Select-Object @{n='UserName';e={$_.Name}},@{n='Groups';e={$groups -join ';'}}
}

Import-Module D:\Scripts\GetLocalAccount.psm1

Get-OSCLocalAccount -ComputerName PC-506 
$la = Get-OSCLocalAccount -ComputerName PC-506
foreach ($acc in $la) 
{ 
    Write-Host $acc.Name
    }




# GET AD User properties
$au = Get-ADUser -Filter {SAMAccountName -like "*rosco*"}
Get-ADUser -Filter {Name -like "*chan*"}

$am = Get-ADUser -Identity richie.meisterburger -Properties MemberOf
$am.MemberOf 
  
Get-ADGroupMember -Identity SecuritisationAdministrator
Add-ADGroupMember -Identity SecuritisationAdministrator fong.chan

get-help Get-ADComputer -examples

$s =  Get-ADComputer -Filter 'Name -like "PC-*"' | Select -Property Name 
foreach ($item in $s)
{
Write-Host $item
Write-Host "-----------"
    
}


# Get local users and their respective groups 
$adsi = [ADSI]"WinNT://$env:PC-506"
$adsi.Children | where {$_.SchemaClassName -eq 'user'} | Foreach-Object {
    $groups = $_.Groups() | Foreach-Object {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
    $_ | Select-Object @{n='UserName';e={$_.Name}},@{n='Groups';e={$groups -join ';'}}
}

# get groups the template (existing) user is a member of:
Get-ADPrincipalGroupMembership -Identity:"CN=Milan van Hoek,OU=Gebruikers,DC=incharge-it,DC=local"
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
Add-ADPrincipalGroupMembership -Identity $DestUser -MemberOf "$group" -Server:"eunomia2016.incharge-it.local" -WhatIf
}


# This keeps me from running the whole script in case I accidentally hit F5
if (1 -eq 1) { exit } 

# get groups the template (existing) user is a member of:
Get-ADPrincipalGroupMembership -Identity:"CN=Jaap Aap,OU=Gebruikers,DC=incharge-it,DC=local"
Get-ADPrincipalGroupMembership -Identity rwo | Select-Object -ExpandProperty name | Out-File -FilePath C:\Users\rwoadmin\Downloads\adgroup.txt

# save the distinguishedName for each group
# enter the existing user 
$SrcUser = 'hs'
# store user's groups
$SrcUserGroups = Get-ADPrincipalGroupMembership -Identity $SrcUser | Select-Object -ExpandProperty distinguishedName
# add saved groups to new user
$DestUser = 'lwi'
# loop door de groepen en voeg deze toe
foreach ( $group in $SrcUserGroups ) {
Add-ADPrincipalGroupMembership -Identity $DestUser -MemberOf "$group" -Server:"mydc01.incharge-it.local" -ErrorAction Continue
}

$groupname = 'Sales'
$all = Get-ADGroupMember -Identity $groupname -Recursive
$all | Out-GridView


function DummyUse {


    # This keeps me from running the whole script in case I accidentally hit F5
    if (1 -eq 1) { exit } 
    
    
    get-aduser -Filter {SamAccountName -like "*shk*" } |fl
    
    get-aduser -Filter {Name -like "*evert*"}
    
    Get-WmiObject win32_operatingsystem -ComputerName PC-666 -ErrorAction Stop
    
    get-aduser rwo -properties * | select -property gidNumber, uidNumber
    
    Test-ComputerSecureChannel -Verbose
    
    # Get groups a user belongs to.
    Get-ADPrincipalGroupMembership -Identity jaap.aap | select Name |sort -Property Name | Out-GridView
    
    # Get members of an AD security group
    Get-ADGroupMember -Identity "DevOps" | Select-Object Name |sort -Property Name | Out-GridView
    
    # get info about an OU
    Get-ADOrganizationalUnit -Filter * -SearchBase "ou=Surface,ou=Domain Computers,dc=incharge-it,dc=local" |fl *
    
    # get all computers in an OU
    Get-ADComputer -Filter * -SearchBase "ou=Surface,ou=Domain Computers, dc=incharge-it, dc=local" |select Name |sort -Property Name
    Get-ADComputer -Filter * -SearchBase "ou=Domain Computers, dc=incharge-it, dc=local" |select Name |sort -Property Name
    
    # find old users
    Get-ADUser -Filter {lastlogondate -lt "January 1, 2018"}
    # and disable account
    #Get-ADUser -Filter {lastlogondate -lt "January 1, 2013"} | Disable-ADAccount
    
    Get-ADUser -Filter {Enabled -eq $false -and lastlogondate -gt "January 1, 2017"}
    
    
    # get uptime of machine
    Get-WmiObject Win32_OperatingSystem -ComputerName localhost | Select-Object LastBootUpTime
    
    # get list 
    Get-ADComputer -Filter * -Property * | Format-Table Name,OperatingSystem,OperatingSystemServicePack,OperatingSystemVersion -Wrap –Auto
    
    # Create new Security Group
    New-ADGroup -GroupCategory:"Security" -GroupScope:"Global" -Name:"L-mho" -Path:"OU=Groups,OU=Linux,DC=incharge-it,DC=local" -SamAccountName:"L-mho" -Server:"eunomia2016.incharge-it.local"
    # Add member to Security Group
    Set-ADGroup -Add:@{'Member'="CN=Richie Meisterburger,OU=Users,DC=incharge-it,DC=local"} -Identity:"CN=L-mho,OU=Groups,OU=Linux,DC=incharge-it,DC=local" -Server:"eunomia2016.incharge-it.local"
    # Add company description to user
    Set-ADUser -Company:"incharge-it" -Identity:"CN=Richie Meisterburger,OU=Gebruikers,DC=incharge-it,DC=local" -Server:"eunomia2016.incharge-it.local"
    # Add groups to user
    Add-ADPrincipalGroupMembership -Identity:"CN=Richie Meisterburger,OU=Gebruikers,DC=incharge-it,DC=local" -MemberOf:"CN=BD_Employees,OU=Security Groups,DC=incharge-it,DC=local","CN=Bioinformatics,OU=Groepen,DC=incharge-it,DC=local" -Server:"eunomia2016.incharge-it.local"
    # remove a group from a user
    Remove-ADPrincipalGroupMembership -Confirm:$false -Identity:"CN=Richie Meisterburger,OU=Gebruikers,DC=incharge-it,DC=local" -MemberOf:"CN=BD_Employees,OU=Security Groups,DC=incharge-it,DC=local" -Server:"eunomia2016.incharge-it.local"
    
    Get-ADPrincipalGroupMembership -Identity:"CN=Richie Meisterburger,OU=Gebruikers,DC=incharge-it,DC=local"
    
    # Create a new AD user
    New-ADUser -DisplayName:"Test User" -GivenName:"Test" -Name:"Test User" -Path:"OU=Gebruikers,DC=incharge-it,DC=local" -SamAccountName:"ttuu" -Server:"eunomia2016.incharge-it.local" -Surname:"User" -Type:"user" -UserPrincipalName:"ttuu@incharge-it.local"
    Set-ADAccountPassword -Identity:"CN=Test User,OU=Gebruikers,DC=incharge-it,DC=local" -NewPassword:"System.Security.SecureString" -Reset:$true -Server:"eunomia2016.incharge-it.local"
    Enable-ADAccount -Identity:"CN=Test User,OU=Gebruikers,DC=incharge-it,DC=local" -Server:"eunomia2016.incharge-it.local"
    Set-ADAccountControl -AccountNotDelegated:$false -AllowReversiblePasswordEncryption:$false -CannotChangePassword:$false -DoesNotRequirePreAuth:$false -Identity:"CN=Test User,OU=Gebruikers,DC=incharge-it,DC=local" -PasswordNeverExpires:$false -Server:"eunomia2016.incharge-it.local" -UseDESKeyOnly:$false
    Set-ADUser -ChangePasswordAtLogon:$true -Identity:"CN=Test User,OU=Gebruikers,DC=incharge-it,DC=local" -Server:"eunomia2016.incharge-it.local" -SmartcardLogonRequired:$false
    # End Create a new AD user
    
    # Change user passwd
    Set-ADAccountPassword -Identity:"CN=Richie Meisterburger,OU=Gebruikers,DC=incharge-it,DC=local" -NewPassword:"System.Security.SecureString" -Reset:$true -Server:"eunomia2016.incharge-it.local"
    # Make usr change password
    Set-ADUser -ChangePasswordAtLogon:$true -Identity:"CN=Richie Meisterburger,OU=Gebruikers,DC=incharge-it,DC=local" -Server:"eunomia2016.incharge-it.local"
    
    # Enable remoting on workstation
winrm qc
Enable-PSRemoting -Force


############ Reset RDP ###################
$clientvm="clientvm-ncq"  

$rdpport=3389  # RDP port 3389 

# Test if machine is available
Test-Connection $clientvm

# test if rdp port is available
Test-NetConnection -ComputerName $clientvm -Port $rdpport

# Disable Remote Desktop
Invoke-Command –Computername $clientvm –ScriptBlock {Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" –Value 1}

# restart the remote desktop service
Invoke-Command –Computername $clientvm –ScriptBlock {Stop-Service -Name UMRDPService}
Invoke-Command –Computername $clientvm –ScriptBlock {Stop-Service -Name Termservice}
Invoke-Command –Computername $clientvm –ScriptBlock {Start-Service -Name Termservice}
Invoke-Command –Computername $clientvm –ScriptBlock {Start-Service -Name UMRDPService}

# Enable Remote Desktop
Invoke-Command –Computername $clientvm –ScriptBlock {Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" –Value 0}

################### End of Reset RDP ##################################



    
    } # End DummyUse