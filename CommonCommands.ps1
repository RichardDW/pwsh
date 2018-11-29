function DummyFunctionToPreventAccidentalRunning {

# Instead of dummy function use:

# This keeps me from running the whole script in case I accidentally hit F5
if (1 -eq 1) { exit } 


# To run an executable from within powershell prepend the command
# with an &

# Help
Get-Help
get-help Invoke-Command -Online
Get-Help Show-Command -ShowWindow
# 
Get-Command | fl *
Get-Command -ParameterName cimsession
Get-Command *disk*

'localhost' | get-inventory | Format-Table *
# Get-Content c:\temp\computers.txt |Get-Inventory | Export-Csv c:\temp\inventory.csv
Get-Content c:\temp\computers.txt |Get-Inventory | ConvertTo-Html | Out-File c:\temp\inventory.html

$proces = Get-Process
Write-Host $proces
$datum = Get-Date
Write-Host $datum

$hostie = Get-Host
Write-Host $hostie

$un = %username%
Get-CimInstance -name root\cimv2\power -ClassName Win32_PowerPlan
Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerPlan

Dir $env:windir | Where-Object { $_.Length -gt 1MB }
Dir $env:windir | Where-Object Length -gt 1MB
$WhiteList = @('Spooler','WinRM','WinDefend')
Get-Service | Where-Object { $WhiteList -contains $_.Name }
Get-Service | Where-Object Name -In $WhiteList

# get OS
$comp = 'sec-nz-dc-02.ams.securities.local'
$comp ; (Get-WmiObject Win32_OperatingSystem -ComputerName $comp ).Name

Get-WmiObject win32_logicaldisk -ComputerName auto-506

Get-Process| Write-Host -ForegroundColor DarkYellow

Get-Process |Out-String -Stream |Write-Host -ForegroundColor Yellow

function prompt { " wolco > " }

# Execution Policy
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

Get-Member

Update-TypeData

# Get the drives
Get-PSDrive

# Show loaded modules
Get-Module
Get-Module -ListAvailable
$env:PSModulePath
Get-Disk
Get-Volume

# Processes
# All objects
Get-Process |Get-Member | Out-Gridview
# Only selected objects come thru the pipe
Get-Process | Select-Object -Property Name, DisplayName | Get-Member | Out-GridView

Get-Process |  Where-Object {$_.Company -like "*icrosoft*" } | fl *
Get-process | 
Where-object { $_.CPU -gt 100 } | Sort-Object -Property name -Verbose
Get-Process| Write-Host -ForegroundColor DarkYellow
Get-Process |Out-String -Stream |Write-Host -ForegroundColor Yellow
Get-Process | Sort-Object VM -Descending | Select-Object Name, VM -First 5 | Format-Table -AutoSize

dir $env:windir |Where-Object Length -gt 1mb
$WhiteList = @('Spooler', 'WinRM', 'WinDefend')
Get-Service -name $WhiteList
Get-service | Where-Object Name -In $WhiteList

$processes = Get-Process
foreach {$proc in $processes) {
    if ($proc.name -like '*notepad*') {
        $proc | Stop-Process
    }
}



$proces = Get-Process
Write-Host $proces

# Use custom properties
get-process | format-table name,@{label="company";expression={$_.MainModule.FileVersionInfo.CompanyName}} -Autosize
Get-Process | Format-Table -Property Name, Id, @{name='VM(MB)';expression={$_.VM / 1MB};formatstring='N2';align='right';width=12},@{n='PM(MB)';e={$_.PM / 1MB};'formatstring'='N2';'align'='right';width=10} -autosize
Get-Process | Select-Object -Property Name, Id, @{name='VM(MB)';expression={$_.VM / 1MB}},@{n='PM(MB)';e={$_.PM / 1MB}}


$MyPSlist = Get-Process
$MyPSlist.Count
$MyPSlist[-1]
$myNewPSlist = Get-Process -Verbose | Sort-Object -Unique
$myNewPSlist.Count
$a = Get-Process lsass
$a.Name
$a[0].Name
$a.length
$b = Get-Process *ss
$b.Name
$b[0].Name
$b.Length



# Services
Get-Service -ComputerName localhost
Get-Service -Name *Http*
Get-Service | Format-Table name, servicehandle, status, servicetype -AutoSize
Get-Service |Get-Member
Start-Service -Name 

$WhiteList = @('Spooler', 'WinRM', 'WinDefend')
Get-Service -name $WhiteList
Get-service | Where-Object Name -In $WhiteList  # PS3
Get-Service | Where-Object { $WhiteList -contains $_.Name }   #  PS2


# Restart Windows Update Service
get-service wuauserv -computername auto-506 | restart-service
psexec \\auto-506 wuauclt /resetauthorization / detectnow

# Text
cat D:\scripts\diskspace.cvs
Get-Content D:\Scripts\diskspace.cvs

$x = [xml](cat .\textfile_with_xml.txt
$x.xml.xml.xml.


#Networking 
#Configure interface
netsh interface ipv4 set address name="Local Area Connection" source=static addr=10.10.10.99 mask=255.255.255.0 gateway=10.10.10.1
New-NetIPAddress -InterfaceAlias "Local Area Connection" -IPAddress 10.10.10.99 -PrefixLength 24 -DefaultGateway 10.10.10.1
Set-DnsClientServerAddress -InterfaceAlias "Local Area Connection" -ServerAddresses 8.8.8.8, 4.4.8.8
# enable DHCP  for interface
Set-NetIPInterface -InterfaceAlias "Local Area Connection" -Dhcp Enabled
Restart-NetAdapter -Name "Local Area Connection" 


# Remoting
# To enable, from command prompt;
# c:> winrm quickconfig

# enable PS Remoting enter following command (as Admin on target server):
Enable-PSRemoting -force


Invoke-Command -ComputerName mydc-01 -ScriptBlock { Get-EventLog Security -Newest 10 }
Invoke-Command -ComputerName myprintsrv-01 -ScriptBlock { Get-Service -name Docker.exe } 

Get-PSSession -ComputerName localhost

#  delegated Admin
#

Get-PSSessionConfiguration
# by default you connect to microsoft.powershell
$s = New-PSSession -ComputerName localhost

Invoke-Command { $PSSessionConfigurationName }
$juniorAdminCreds = Get-Credential JUPITER\richa_000
$s = New-PSSession -ComputerName localhost -Credential $juniorAdminCreds

# create a new session that our junior admin can access
Register-PSSessionConfiguration -Name JuniorEndpoint -ShowSecurityDescriptorUI -Force

$s  = New-PSSession -ComputerName localhost -ConfigurationName JuniorEndpoint -Credential $juniorAdminCreds
Invoke-Command $s { Get-Command }
Invoke-Command $s { Get-Service }

# give it a different set of credntials to run commands
Set-PSSessionConfiguration -Name JuniorEndpoint -RunAsCredential JUPITER\richard -Force
$s  = New-PSSession -ComputerName localhost -ConfigurationName JuniorEndpoint -Credential $juniorAdminCreds

Invoke-Command $s { Get-Service }
Invoke-Command $s { $PSSenderInfo }

# To restrict the commands the junior admin can rub  we use session configuration files...
New-PSSessionConfigurationFile -Path c:\Endpoint.pssc -ModulesToImport Microsoft.Powershell.Management -VisibleCmdlets Get-Service -SessionType RestrictedRemoteServer
# this creates the  c:\Endpoint.pssc file

ise c:\Endpoint.pssc

Register-PSSessionConfiguration -Name JuniorEndpoint -Path c:\Endpoint.pssc -RunAsCredential JUPITER\richard -ShowSecurityDescriptorUI -Force

$s  = New-PSSession -ComputerName localhost -ConfigurationName JuniorEndpoint -Credential $juniorAdminCreds

Invoke-Command $s { Get-Service }
Invoke-Command $s { Get-Command }



Get-PSDrive
# credentials on PSDrive
New-PSDrive -Name Share -PSProvider FileSystem -Root \\localhost\e$ -Credential JUPITER\richard

cd wsman

# Hardware

get-wmiobject Win32_PhysicalMemory -ComputerName mydc-01 |
select @{Label="Device Location";Expression={$_.DeviceLocator}},`
DataWidth, @{Label="Capacity";Expression={"{0,12:n0} MB" -f ($_.Capacity/1mb)}}, PartNumber, SerialNumber, Speed

# get free disk size
Get-WmiObject -Class Win32_logicalDisk -ComputerName localhost -Filter "DriveType=3" |
Select-Object PSComputerName,
@{name='FreeSpace(GB)';expression={$PSItem.freespace / 1GB -as [int]}},
@{name='Size(GB)';expression={$PSItem.Size / 1GB -as [int]}},
@{name='FreePercent';expression={$PSItem.FreeSpace / $PSItem.Size * 100 -as [int]}} |
Format-Table -AutoSize


# Type of computer can be determined by the WMI class SystemEnclosure by getting the ChassisType
Get-WmiObject Win32_systemEnclosure -ErrorAction SilentlyContinue -computerName (get-Content c:\temp\pclist.txt) | 
foreach {Write-Host "$i Chassistype is:" $_.Chassistypes}

get-wmiobject -Class win32_computersystem -computername localhost | fl *
Get-WmiObject -class win32_logicaldisk -ComputerName PC-506

# get NIC
Get-WmiObject -class win32_networkadapterconfiguration -computername PC-009| format-table -wrap | 
out-file -width 256 -filepath d:\scripts\networkadapter.txt

# Get IP Addresses
[Net.DNS]::GetHostAddresses('') | select-object -expandproperty IPAddressToString

Get-CimInstance -name root\cimv2\power -ClassName Win32_PowerPlan
Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerPlan

#get screen resolution(s)
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Screen]::AllScreens
[System.Windows.Forms.Screen]::PrimaryScreen
[System.Windows.Forms.Screen]::AllScreens | Measure-Object | Select-Object -ExpandProperty Count


# get OS
$comp = 'mydc-01.incharge-it.local'
$comp ; (Get-WmiObject Win32_OperatingSystem -ComputerName $comp ).NameOut


Get-WmiObject -Class Win32_product -ComputerName mydc-03 | Out-File d:\temp\hv003.txt 
Get-WmiObject -Class Win32_product -ComputerName mydc-02 -Filter {Name -like "*" } 

Get-WmiObject -Class Win32_product -ComputerName localhost |ft name, ident* 
$ci = Get-CimInstance -ClassName win32_product -Computername localhost | Where-Object  {$_.IdentifyingNumber -eq "{CDFB453F-5FA4-4884-B282-F46BDFC06051}"} 

$wi = Get-WmiObject -Class win32_product -Computername localhost | Where-Object  {$_.IdentifyingNumber -eq  "{B704D3AE-4443-40BA-B8B3-F0762ED4E8BC}" }

Get-WmiObject -Class win32_product -Computername localhost | Where-Object  {$_.Name -like "*Quest*"}

# Networking
Get-NetAdapter
Get-NetAdapterAdvancedProperty
Get-NetAdapterBinding
Get-NetIPAddress
Get-NetIPConfiguration
Get-NetIPInterface
Test-NetConnection
Get-AppBackgroundTask

# Web
function Get-LatestArticles
{
    (Invoke-WebRequest -Uri 'http://howtogeek.com').links | fl * 
    
    # Where-Object class -eq "title".Title
}
Get-LatestArticles


# FILE

Dir $env:windir | Where-Object { $_.Length -gt 1MB } # PS2
Dir $env:windir | Where-Object Length -gt 1MB   # PS3

get-childitem -Path s:\ |where {$_.Name -like "my_backup_$((get-date).tostring("yyyy_MM_dd"))_*.bak"}
 
 # Shares
$u = "te.st"
new-item -Path d:\Users\$u -ItemType Directory
net share t_$u=d:\Users\$u /GRANT:$u,FULL

# Objects
$objShell = New-Object -com Shell.Application
$objshell.help


# Method signature output
$sw = New-Object System.IO.StreamWriter "c:\endpoint.pssc"
$sw | Get-Member
$sw.Write

# Web Cmdlets
Invoke-RestMethod http://blogs.msdn.com/b/powershell/rss.aspx | select title, pubdate

Invoke-RestMethod http://blogs.msdn.com/b/powershell/rss.aspx | select title, pubdate | ConvertTo-Json

function GetFlightStatus($flightNumber) {
    $r = Invoke-WebRequest -Uri http://www.bing.com/search?q=flight+status+for+$flightNumber
    ($r.allElements | ? { $_.class -eq "ans" })[0].outertext
}

GetFlightStatus KLM+5390


# LOG

$applog = New-Object -TypeName System.Diagnostics.EventLog -ArgumentList application
$applog |Get-Member -MemberType Property
$applog |Get-Member -MemberType Methods
$applog.Entries
$syslog = New-Object -TypeName System.Diagnostics.EventLog -ArgumentList security

Get-CimInstance win32_service
Get-CimInstance win32_bios
Get-CimInstance win32_computersystem
Get-CimInstance win32_diskdrive |fl *
Get-CimInstance win32_networkprotocol

Get-CimInstance -ClassName Win32_Service|Get-Member
Get-CimInstance -ClassName Win32_Process|Get-Member

####
$x, $y = Get-CimInstance Win32_Process
$x|gm
$x.pstypenames
$x.CimClass|gm

Get-CimClass -ClassName *disk*

Get-CimClass win32* -MethodName Term*
#####

Get-CimInstance win32_service -Filter "startmode = 'auto' AND state != 'running'" -ComputerName localhost

Get-CimInstance win32_service -Filter "startmode = 'manual' AND state = 'running'" -ComputerName localhost | select name, startname, status, state

get-help ConvertTo-Html
get-childitem C:\dell | ConvertTo-Html > d:\temp\usage.htm
$s = get-childitem C:\dell -Recurse
Get-ChildItem c:\dell -File -recurse

Get-Module -ListAvailable

$module = Import-Module BitsTransfer -PassThru
# find path of the module
$module.ModuleBase
# find required .NET assemblies
$module.RequiredAssemblies


# Quick rename multiple files
$Global:i = 10
Get-ChildItem -Path C:\Temp -Filter *.txt |
    Rename-Item -NewName { "textdoc_$i.txt"; $Global:i++}


# find installed program and deinstall it
# read in list of computers
$computers = Get-Content D:\Scripts\hyperv.lst
$computers = Get-Content D:\scripts\hyperv_cluster.lst

$cred = Get-Credential

foreach ($c in $computers)
{
    # change the search criteria (*java*) to find the program you want
    Get-WmiObject -Class win32_product -Computername $c | Where-Object {($_.Name  -like "*agent*" ) -or ($_.Vendor  -like "*intel*" )}  |
    Select PSComputerName, name, version, identifyingnumber
    }

foreach ($c in $computers)
{
    # working on host
    Write-host "Uninstalling on host" $c
    Invoke-Command -ComputerName $c -Credential $cred -ScriptBlock {
    #  assign the program by identifying number to variable
    $wi = Get-WmiObject -Class win32_product -ComputerName $using:c | Where-Object  {($_.IdentifyingNumber -eq  "{5010A712-721E-4B45-8ED2-6AF5338EF697}") -or ($_.IdentifyingNumber -eq  "{DA9CF191-5E6A-4F96-98AD-9DB99BE611C0}")  }
    # uninstall the program
    $wi.Uninstall() 
    }    
}



 $wi = Get-WmiObject -Class win32_product -Computername mydc-020 | Where-Object  {($_.IdentifyingNumber -eq  "{5010A712-721E-4B45-8ED2-6AF5338EF697}") -or ($_.IdentifyingNumber -eq  "{DA9CF191-5E6A-4F96-98AD-9DB99BE611C0}")  }

 Get-service -ComputerName mydc-020

 (Get-WmiObject -Class win32_product -Filter "IdentifyingNumber='{5010A712-721E-4B45-8ED2-6AF5338EF697}'" -ComputerName sec-hyperv-020).Uninstall()
 (Get-WmiObject -Class win32_product -Filter "IdentifyingNumber='{DA9CF191-5E6A-4F96-98AD-9DB99BE611C0}'" -ComputerName sec-hyperv-020).Uninstall()


 $ Search thru a list
 foreach($line in Get-Content .\file.txt) {
    if($line -match $regex){
        # Work here
    }
}


Get-Content .\file.txt | ForEach-Object {
    if($_ -match $regex){
        # Work here
    }
}
 
 
 
 
} # end DummyFunctionToPreventAccidentalRunning
