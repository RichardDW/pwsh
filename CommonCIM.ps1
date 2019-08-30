## http://blogs.msdn.com/b/powershell/archive/2013/08/19/cim-cmdlets-some-tips-amp-tricks.aspx

Get-CimInstance -ClassName win32_logicaldisk |
Select DeviceID,Size,@{Name="Used";Expression = {$_.size - $_.freespace}},
@{Name="PctUsed";Expression={ (($_.size - $_.freespace) /$_.size) * 100}}


# Get all CIM Cmdlets
Get-Command –module CimCmdlets

# Type in the password when you are prompted
$creds = Get-Credential -Credential username<!--[if !supportAnnotations]--><!--[endif]-->
 
# Save credentials for future use
$creds | Export-Clixml -Path c:\a.clixml
 
# Use the saved credentials when needed
$savedCreds = Import-Clixml -Path C:\a.clixml
 
# Create CimSession with Credentials
$session = New-CimSession –ComputerName “machineName”  -Credentials $savedCreds

# If the ComputerName parameter is not added, the cmdlet uses DCOM/COM
# Creates DCOM session
$session = New-CimSession
# Performs enumerate over DCOM
$inst = Get-CimInstance Win32_OperatingSystem                  
 
# If ComputerName is added, the cmdlets go over WS-Man 
$session = New-CimSession –ComputerName localhost
$inst = Get-CimInstance Win32_OperatingSystem –ComputerName localhost

# DCOM Session
$sessionOp = New-CimSessionOption –Protocol DCOM
$sessionDcom = New-CimSession –SessionOption $sessionOp –ComputerName localhost
 
# WS-Man Session: the parameter UseSSL added to the New-CimSessionOption command specified the WS-Man protocol
$sessionOp2 = New-CimSessionOption –UseSSL
$sessionWSMAN = New-CimSession –SessionOption $sessionOp2 –ComputerName localhost
# Create a CimSession using Default protocol
New-CimSession –ComputerName localhost –SessionOption (New-CimSessionOption –Protocol Default) 
# Perform Get-CimInstance using computerName
$time1 = Measure-Command { 1..100 | %{ Get-CimInstance –ClassName CIM_ComputerSystem –ComputerName remoteMachine } }
 
# Create a CimSession
$session = New-CimSession –ComputerName remoteComputer
$time2 = Measure-Command { 1..100 | %{ Get-CimInstance –ClassName CIM_ComputerSystem –CimSession $session } }

# Create multiple sessions 
$allSessions = New-CimSession -ComputerName “machine1”, “machine2”, “machine3” –Credentials $credentials
 
# Fan-out with CIM session Array
Get-CimInstance –ClassName Win32_OperatingSystem –CimSession $allSessions
 
# Reboot all machines in one line
Invoke-CimMethod –ClassName Win32_OperatingSystem –MethodName Reboot –CimSession $allSessions
 
 # OR
 
Invoke-CimMethod –ClassName Win32_OperatingSystem –MethodName Reboot –ComputerName “Machine1”, Machine2”,”Machine3”
# Get instance from a class
$session = New-CimInstance -ComputerName machine1
$inst = Get-CimInstance –Query “Select * from TestClass where v_key = 2” –Namespace root/test –CimSession $session
 
# Pass CIM instance 
$props = @{ boolVal = $true }
$inst | Set-CimInstance –CimInstance $inst –Property $props
 
# OR
 
# Pipe result of get into set
Get-CimInstance –Query “Select * from TestClass where v_key = 2” –Namespace root/test –CimSession $session | Set-CimInstance –CimInstance $inst –Property $props

# Non DMTF resource URI 
$resourceuri = "http://intel.com/wbem/wscim/1/amt-schema/1/AMT_PETFilterSetting"
 
# Get instances
$inst = Get-CimInstance -Namespace $namespace -ResourceUri $resourceuri -CimSession $session
 
# Query instances
$inst = Get-CimInstance -Query $query -Namespace $namespace -ResourceUri $resourceuri -CimSession $session
 
# Modify instance
$propsToModify = @{LogOnEvent=$false}
Set-CimInstance -InputObject $inst -Property $ propsToModify -ResourceUri $resourceuri -CimSession $session
 
# Creating CIM session when the server/CIMOM does not support TestConnection 
$session = New-CimSession –CN “machineName”  -Credentials $creds –SkipTestConnection

# Default HTTP port for WS-Man on Windows
$httpPort = 5985                        
# Default HTTPS port for WS-Man on Windows
$httpsPort = 5986        
 
# Port parameter is exposed by New-CimSession and not New-CimSessionOption
$session = New-CimSession –CN “machineName”  -Credentials $creds –Port $httpPort

# If using HTTPS. 
$sop = New-CimSessionOption –UseSSL
$session = New-CimSession –CN “machineName”  -Credentials $creds –Port $httpsPort
 
# Get instance of Win32_LogicalDisk class with DriveType =3 (hard drives)
$disks = Get-CimInstance -class Win32_LogicalDisk -Filter 'DriveType = 3'
 
# Get the all instances associated with this disk
Get-CimAssociatedInstance -CimInstance $disks[0]
 
# Get instances of a specific type
Get-CimAssociatedInstance -CimInstance $disks[0] -ResultClassName Win32_DiskPartition
 
# Finding associated instances through a specific CIM relationship 
Get-CimAssociatedInstance -CimInstance $disks[0] -Association Win32_LogicalDiskRootDirectory

#################################################### 


# Using tab completion for CIM cmdlet parameters ( Tab+Space in ISE shows a drop down)

Get-CimInstance –Namespace <Tab> #Finding top-level namespaces

# Tab completion for class names

# If namespace is not specified, shows classes from default root/cimv2 namespace

Get-CimInstance -ClassName *Bios<Tab>

Get-CimInstance –Namespace root/Microsoft/Windows/smb –ClassName <tab>

# Note: Tab completion only works for local machine.

#Using Get-CimClass for advanced class search

#All classes in root/cimv2

Get-CimClass 

#Classes named like disk

Get-CimClass -ClassName *disk*

# The Cmdlet makes querying much easier (what would require scripting before)

# Get all classes starting with "Win32" that have method starting with "Term" 

Get-CimClass Win32* -MethodName Term* 

# Get classes starting with "Win32" that have a property named "Handle"

Get-CimClass Win32* -PropertyName Handle

# Get classes starting with "Win32" that have the "Association" qualifier

Get-CimClass Win32* -QualifierName Association

#Find classes used for events

Get-CimClass -Namespace root/Microsoft/Windows/smb -class *Smb* -QualifierName Indication

Get-CimInstance -Class Win32_BIOS | Select-Object -Property *

# Get-CimInstance was designed to be similar to the Get-WmiObject

# WMI Cmdlet : Get-WmiObject -class Win32_Process

# WsMan Cmdlet : get-wsmaninstance wmicimv2/win32_process -Enumerate

# The default value of -Namespace is root/cimv2, and the default value of -ComputerName is local computer 

Get-CimInstance -Class Win32_Process

# Filtering using WQL

Get-CimInstance -Query "SELECT * FROM Win32_Process WHERE Name Like 'power%'" 

# use the -Filter parameter with -classname

Get-CimInstance -Class Win32_Process -Filter "Name Like 'power%'" 

#Retrieving a subset of properties : To reduce memory and on-the-wire footprint

Get-CimInstance -Class Win32_Process -Property Name, Handle 

#Only get the key properties

Get-CimInstance -Class Win32_Process -KeyOnly

########################## Looking into CimInstance #########################

$x, $y = Get-CimInstance Win32_Process

$x | gm

# The object contains the full CIM class derivation hierarchy

$x.pstypenames

# The object also has a reference to its class declaration

$x.CimClass | gm

# DateTime values are returned as strings

Get-WmiObject Win32_OperatingSystem | Select *Time*

# DateTime values are returned as System.DateTime

Get-CimInstance Win32_OperatingSystem | Select *Time*#
 
# Get instance of Win32_LogicalDisk class with DriveType =3 (hard drives)

$disk1, $diskn = Get-CimInstance -class Win32_LogicalDisk -Filter 'DriveType = 3'

$disk1

# Get the all instances associated with this disk

Get-CimAssociatedInstance -CimInstance $disk1

# Get instances of a specific type

Get-CimAssociatedInstance -CimInstance $disk1 -ResultClassName Win32_DiskPartition

# Finding associated instances through a specific CIM relationship 

Get-CimAssociatedInstance -CimInstance $diskn -Association Win32_LogicalDiskRootDirectory
 
$class = Get-CimClass Win32_Process

$class.CimClassMethods

# Get the parameters of the Create method

$class.CimClassMethods["Create"].Parameters

# Invoke the static Create method on the Win32_Process class to create an instance of the Notepad 

# application. Notice that the method parameters are given in a hash table since CIM method arguments

# are unordered by definition. 

Invoke-CimMethod -Class win32_process -MethodName Create -Argument @{CommandLine='notepad.exe';

CurrentDirectory = "c:\windows\system32"}

# Get the owners of the running Notepad instances

$result = Invoke-CimMethod -Query 'SELECT * FROM Win32_Process WHERE name like "notepad%"' -MethodName GetOwner

# The result has the returned value and out parameters of the method

$result
 
# CimInstances are serialized and deserialized with full fidelity

$x = Get-CimInstance Win32_Service 

$x

$x[0].pstypenames

$x | Export-CliXml t1.xml

$y = Import-CliXml .\t1.xml

$y

$y[0].pstypenames

# The deserialized objects are identical to the ones obtained from the server

diff ($y) (Get-CimInstance win32_service )
 
$props = @{v_Key = [UInt64] 8;}

# If ComputerName parameter is used, the cmdlets create an implicit session during the execution.

$inst = New-CimInstance -ClassName TestClass -Namespace root\test -Key v_Key -Property $props -ComputerName SecondWin8Server

# Create a session

$session = New-CimSession –ComputerName SecondWin8Server

# Use the session 

$inst = New-CimInstance -ClassName TestClass -Namespace root\test -Key v_Key -Property $props –CimSession $session
 
# OLD: One liner to get ComputerSystem information

Get-WmiObject Win32_ComputerSystem

# NEW:

Get-CimInstance Win32_ComputerSystem

# ClassName is position and mandatory.

# Namespace default is root/cimv2 namespace

#WMI Cmdlet – with classnames and Namespace

Get-WmiObject –ClassName Win32_Process –Namespace root/cimv2

#CIM cmdlet follows the same pattern

Get-CimInstance –ClassName Win32_Process –Namespace root/cimv2
 
get-wmiobject win32_service -filter "startmode='auto' AND state<>'Running'" | 
Select Name,State

$computers = "eq-manage-01","sec-manage4"
get-wmiobject win32_service -computer $computers -filter "startname like '%administrator%'"|
     Select Name,startmode,state,startname,systemname

 
get-ciminstance  win32_service -filter "name = 'spooler'" -Computername $servers | Select Name,Status,PSComputername

get-ciminstance win32_service -filter "StartMode = 'auto' and State = 'Stopped'" -Computername eq-manage-01



$servers | foreach {
$obj = [pscustomobject]@{
  Computername = $_.ToUpper()
  Service = "Spooler"
  Verified = "Unknown"
 }
$s = get-ciminstance win32_service -filter "name = 'spooler'" -ComputerName $_
if ($s) {
  $obj.Verified = $True
}
else {
  $obj.verified = $False
}
#write the object to the pipeline
$obj
}

