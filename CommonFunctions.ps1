<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>

# REGISTRY

function Delete_RegKey {
$MachineName = 'PC-666'
$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $MachineName)
 
# connect to the needed key :
 
$regKey= $reg.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate",$true )
 
# and delete the SusClientId subkey, if it exists
 
	foreach ($key in $regKey.GetValueNames())
	{    
    	if ($key -eq "SusClientId")
    	{

			$regKey.DeleteValue($key)     
    	}
	}
}

function Get-LoggedOnUsers {            

[cmdletbinding()]            
param(            

[parameter(valuefrompipelinebypropertyname=$true)]            
[string]$ComputerName = $env:computername            

)            

begin {}            
process {            

[object[]]$sessions = Invoke-Expression "PsLoggedon.exe -x -l \$ComputerName 2> null" |             
        Where-Object {$_ -match '^s{2,}((?w+)\(?S+))'} |             
        Select-Object @{             
            Name='Computer'             
            Expression={$ComputerName}             
        },             
        @{             
            Name='Domain'             
            Expression={$matches.Domain}             
        },             
        @{             
            Name='User'             
            Expression={$Matches.User}             
        }             

    IF ($Sessions.count -ge 1)             
    {             
        return $sessions            
    }             
    Else             
    {             
        'No user logins found'            
    }             

}            
end {}            
}



# HARDWARE 

function Get-Dimm ($comp)
{
	get-wmiobject Win32_PhysicalMemory -ComputerName $comp |
	select @{Label="Device Location";Expression={$_.DeviceLocator}},`
	DataWidth, @{Label="Capacity";Expression={"{0,12:n0} MB" -f ($_.Capacity/1mb)}}, PartNumber, SerialNumber, Speed
	}
	
function Get-CompInfo ($comp)
{
	Write-Host "Computer Info"
	get-wmiobject Win32_ComputerSystem -ComputerName $comp |
	select Name, Description, @{Label="DNS Host Name"; Expression={$_.DNSHostName}},`
	Domain, Manufacturer, Model, @{Label="# Processors";Expression={$_.NumberOfProcessors}},`
	@{Label="System Type";Expression={$_.SystemType}}, @{Label="Physical Memory";Expression={"{0,12:n0} MB" `
	-f ($_.TotalPhysicalMemory/1mb)}}
	Write-Host "CPU Info" 
	get-wmiobject Win32_Processor -ComputerName $comp | select Name, Description, Revision, L2CacheSize
	}

function Get-Inventory ($comp)
{
    PROCESS {
        $os = Get-WmiObject win32_operatingsystem -computerName $comp
        $bios = Get-WmiObject win32_bios -computerName $comp
        $obj = New-Object psobject
        $obj | Add-Member NoteProperty ComputerName $comp
        $obj | Add-Member NoteProperty SPVersion ($os.servicepackmajorversion)
        $obj | Add-Member NoteProperty BIOSSerial ($bios.SMBBIOSBIOSVersion)
        $obj | Add-Member NoteProperty OSBuild ($os.buildnumber)
        Write-Output $obj
        
    }
}

function Get-Inventory2 {
    BEGIN {
        del c:\temp\errors.txt -ErrorAction 'silentlycontinue'
        }
    PROCESS {
        $computername = $_
        try {
            $os = Get-WmiObject win32_operatingsystem -ComputerName $computername -ErrorAction 'stop'
            $bios = Get-WmiObject win32_bios -ComputerName $computername -ErrorAction 'stop'
            } catch {
                $computername | Out-File c:\temp\errors.txt -Append
            }
        $obj = New-Object psobject
        $obj | Add-Member noteproperty ComputerName ($computername)
        $obj | Add-Member noteproperty OSVersion ($os.caption)
        $obj | Add-Member noteproperty SPVersion ($os.servicepackmajorversion)
        $obj | Add-Member noteproperty BIOSSerial ($bios.serialnumber)
        $obj | Add-Member noteproperty OSBuild ($os.buildnumber)
        Write-Output $obj
    }
}


	
	function Get-SecSystemInfo {
    <#
    .SYNOPSIS
    Queries critical computer information from a single machine.
    .DESCRIPTION
    Queries OS and hardware information
    .PARAMETER ComputerName
    The name or IP of computer to query
    .EXAMPLE
    .\Get-SystemInfo -ComputerName WhatEVER
    .EXAMPLE
    .\Get-SystemInfo -ComputerName WhatEVER | Format-Table *
    Info in a table
    #>

    param(
        [string]$ComputerName = 'localhost'
    )

    $os = Get-WmiObject -Class win32_operatingsystem -ComputerName $ComputerName
    $cs = Get-WmiObject -Class win32_computersystem -ComputerName $ComputerName
    $props = @{'ComputerName'=$ComputerName;
                'OSVersion'=$os.version;
                'OSBuild'=$os.buildnumber;
                'SPVersion'=$os.servicepackmajorversion;
                'Model'=$cs.model;
                'Manufacturer'=$cs.manufacturer;
                'RAM'=$cs.totalphysicalmemory / 1GB -as [int];
                'Sockets'=$cs.numberofprocessors;
                'Cores'=$cs.numberoflogicalprocessors}
    $obj = New-Object -TypeName PSObject -Property $props
    Write-Output $obj
}

#Get-SystemInfo -ComputerName localhost | Select-Object -Property *,@{n='RAM(GB)';e={$_.RAM / 1GB -as [int]}} -ExcludeProperty RAM

Get-SecSystemInfo -ComputerName localhost | Select-Object -Property *
	
Function Test-MemoryUsage {
[cmdletbinding()]
Param()

$os = Get-Ciminstance Win32_OperatingSystem
$pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)

if ($pctFree -ge 45) {
$Status = "OK"
}
elseif ($pctFree -ge 15 ) {
$Status = "Warning"
}
else {
$Status = "Critical"
}

$os | Select @{Name = "Status";Expression = {$Status}},
@{Name = "PctFree"; Expression = {$pctFree}},
@{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,2)}},
@{Name = "TotalGB";Expression = {[int]($_.TotalVisibleMemorySize/1mb)}}

}


Function Show-MemoryUsage {

[cmdletbinding()]
Param()

#get memory usage data
$data = Test-MemoryUsage

Switch ($data.Status) {
"OK" { $color = "Green" }
"Warning" { $color = "Yellow" }
"Critical" {$color = "Red" }
}

$title = @"

Memory Check
------------
"@

Write-Host $title -foregroundColor Cyan

$data | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor $color

}

set-alias -Name smu -Value Show-MemoryUsage	
	
	
	
	
# SERVICES

function Restart-ServiceEx {  
    [CmdletBinding( SupportsShouldProcess=$true, ConfirmImpact='High')]  
    param(  
    $computername = 'PC-666',  
    $service = 'wuauserv',  
    $credential = $null  
    )  
  
# create list of clear text error messages  
    $errorcode = 'Success,Not Supported,Access Denied,Dependent Services Running,Invalid Service Control'  
    $errorcode += ',Service Cannot Accept Control, Service Not Active, Service Request Timeout'  
    $errorcode += ',Unknown Failure, Path Not Found, Service Already Running, Service Database Locked'  
    $errorcode += ',Service Dependency Deleted, Service Dependency Failure, Service Disabled'  
    $errorcode += ',Service Logon Failure, Service Marked for Deletion, Service No Thread'  
    $errorcode += ',Status Circular Dependency, Status Duplicate Name, Status Invalid Name'  
    $errorcode += ',Status Invalid Parameter, Status Invalid Service Account, Status Service Exists'  
    $errorcode += ',Service Already Paused'  
  
    # if credential was specified, use it...  
    if ($credential) {  
        $service = Get-WmiObject Win32_Service -ComputerName $computername -Filter "name=""$service""" -Credential $credential  
    } else {  
        # else do not use this parameter:  
        $service = Get-WmiObject Win32_Service -ComputerName $computername -Filter "name=""$service"""   
    }  
  
    # if service was running already...  
    $servicename = $service.Caption  
    if ($service.started) {  
        # should action be executed?   
        if ($pscmdlet.ShouldProcess($computername, "Restarting Service '$servicename'")) {  
   # yes, stop service:  
            $rv = $service.StopService().ReturnValue  
            if ($rv -eq 0) {  
                # ...and if that worked, restart again  
                $rv = $service.StartService().ReturnValue  
            }  
   # return clear text error message:  
            $errorcode.Split(',')[$rv]  
        }   
    } else {  
        # else if service was not running yet, start it:  
        if ($pscmdlet.ShouldProcess($computername, "Starting Service '$servicename'")) {  
            $rv = $service.StartService().ReturnValue  
            $errorcode.Split(',')[$rv]  
        }   
    }  
} 

<#
.SYNOPSIS
Get-Uptime retrieves boot up information from a Aomputer.
.DESCRIPTION
Get-Uptime uses WMI to retrieve the Win32_OperatingSystem
LastBootuptime property. It displays the start up time
as well as the uptime.

Created By: Jason Wasser @wasserja
Modified: 8/13/2015 01:59:53 PM  
Version 1.4

Changelog:
 * Added Credential parameter
 * Changed to property hash table splat method
 * Converted to function to be added to a module.

.PARAMETER ComputerName
The Computer name to query. Default: Localhost.
.EXAMPLE
Get-Uptime -ComputerName SERVER-R2
Gets the uptime from SERVER-R2
.EXAMPLE
Get-Uptime -ComputerName (Get-Content C:\Temp\Computerlist.txt)
Gets the uptime from a list of computers in c:\Temp\Computerlist.txt.
.EXAMPLE
Get-Uptime -ComputerName SERVER04 -Credential domain\serveradmin
Gets the uptime from SERVER04 using alternate credentials.
#>
Function Get-Uptime {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,
                        Position=0,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true)]
        [Alias("Name")]
        [string[]]$ComputerName=$env:COMPUTERNAME,
        $Credential = [System.Management.Automation.PSCredential]::Empty
        )

    begin{}

    #Need to verify that the hostname is valid in DNS
    process {
        foreach ($Computer in $ComputerName) {
            try {
                $hostdns = [System.Net.DNS]::GetHostEntry($Computer)
                $OS = Get-WmiObject win32_operatingsystem -ComputerName $Computer -ErrorAction Stop -Credential $Credential
                $BootTime = $OS.ConvertToDateTime($OS.LastBootUpTime)
                $Uptime = $OS.ConvertToDateTime($OS.LocalDateTime) - $boottime
                $propHash = [ordered]@{
                    ComputerName = $Computer
                    BootTime     = $BootTime
                    Uptime       = $Uptime
                    }
                $objComputerUptime = New-Object PSOBject -Property $propHash
                $objComputerUptime
                } 
            catch [Exception] {
                Write-Output "$computer $($_.Exception.Message)"
                #return
                }
        }
    }
    end{}
}

function Get-LoggedOnUsers {            

[cmdletbinding()]            
param(            

[parameter(valuefrompipelinebypropertyname=$true)]            
[string]$ComputerName = $env:computername            

)            

begin {}            
process {            

[object[]]$sessions = Invoke-Expression "PsLoggedon.exe -x -l \$ComputerName 2> null" |             
        Where-Object {$_ -match '^s{2,}((?w+)\(?S+))'} |             
        Select-Object @{             
            Name='Computer'             
            Expression={$ComputerName}             
        },             
        @{             
            Name='Domain'             
            Expression={$matches.Domain}             
        },             
        @{             
            Name='User'             
            Expression={$Matches.User}             
        }             

    IF ($Sessions.count -ge 1)             
    {             
        return $sessions            
    }             
    Else             
    {             
        'No user logins found'            
    }             

}            
end {}            
}

function SetServiceStartToAutoMatic($serviceName = $(throw "Service Name was not specified")){  
      $service = Get-Service $serviceName  
      $startType = Get-WmiObject -Query "Select StartMode From Win32_Service Where Name='$($serviceName)'"  
   
      if ($startType.StartMode -eq "Manual"){  
           Set-Service $serviceName –StartupType Automatic  
      }  
 }  
   
 function StartServiceIfStopped($serviceName = $(throw "Service Name was not specified")){  
      $service = Get-Service $serviceName  
      if ($service.Status -eq "Stopped"){  
           Start-Service $serviceName  
      }  
 }  
   
 function Main(){  
      $smtpServiceName = "SMTPSVC"  
      SetServiceStartToAutoMatic $smtpServiceName  
      StartServiceIfStopped $smtpServiceName  
 }  
   
 Main  



function pow1 ($base, $expo)
{
    [System.Math]::Pow($base, $expo)
}

function pow2
{
    Param (
    $base = 5,
    $expo = 10
    )
    [System.Math]::Pow($base, $expo)
    $args
}

function pow3
{
    [System.Math]::Pow($args[0], $args[1])
    $args
 }
 
 function dup
 {
    Begin
    {
        Write-Host 'initialization'
    }
    Process
    {
        Write-Host ( "`t" + $_ + $_)
    }
    End
    {
        Write-Host 'cleanup'
    }
 }

 function get-localadmins{
  [cmdletbinding()]
  Param(
  [string]$computerName
  )
  $group = get-wmiobject win32_group -ComputerName $computerName -Filter "LocalAccount=True AND SID='S-1-5-32-544'"
  $query = "GroupComponent = `"Win32_Group.Domain='$($group.domain)'`,Name='$($group.name)'`""
  $list = Get-WmiObject win32_groupuser -ComputerName $computerName -Filter $query
  $list | %{$_.PartComponent} | % {$_.substring($_.lastindexof("Domain=") + 7).replace("`",Name=`"","\")}
}

