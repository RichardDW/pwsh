function DummyFunctionToPreventAccidentalRunning {

Get-ChildItem C:\Windows | Out-File d:\tmp\MyDir.txt
Get-Content d:\tmp\MyDir.txt
Rename-Item -Path D:\tmp\MyDir.txt -NewName WindowsDir.txt
New-Item -ItemType directory -Path d:\LabOutput
Copy-Item -Path D:\tmp\WindowsDir.txt -Destination D:\LabOutput
Remove-Item -Path D:\tmp\WindowsDir.txt
Get-Process | Out-File D:\LabOutput\Procs.txt
Get-Process | Sort-Object -Property CPU -Descending |gm 
Get-Process | ConvertTo-Html | Out-File D:\LabOutput\procs.html
Get-Process | Export-Clixml -Path D:\LabOutput\Procs.xml
Get-Service | Export-Clixml -Path D:\LabOutput\Services.xml
Get-Content D:\LabOutput\Procs.txt 

get-process | where { $_.workingset -gt 100mb}
(dir $home\Documents -file).where({$_.lastwritetime.Year -le 2018})
if ($PSVersionTable.PSVersion.Major -ge 3) { "OK" }


Get-CimInstance win32_logicaldisk -filter "deviceID='c:'" | Select-Object -Property DeviceId, Size,FreeSpace

# one line random character generator
-join ('abcdefghkmnrstuvwxyzABCDEFGHKLMNPRSTUVWXYZ23456789$%&*#'.ToCharArray() | Get-Random -Count 12) 

update-help
get-alias
help -Category Provider
get-help Format-List -ShowWindow
get-help Get-ChildItem -ShowWindow

Get-Process | Format-Table -Property Name, Id, @{name='VM(MB)';expression={$_.VM / 1MB};formatstring='N2';align='right';width=12},@{n='PM(MB)';e={$_.PM / 1MB};'formatstring'='N2';'align'='right';width=10} -autosize 

Get-Process | Select-Object -Property Name, Id, @{name='VM(MB)';expression={$_.VM / 1MB}},@{n='PM(MB)';e={$_.PM / 1MB}} |gm

 get-process |Select-Object -Property * -First 1 
 Get-Process |fl * -GroupBy PriorityClass
 Get-Service | Select-Object -Property * -First 1 |gm
 Get-Service | Format-List * |gm 
 Get-Process | Where-Object -
 Get-Command -Noun *object*

$myservice = get-service -computername test.server.local | where {$_.name -like "*Docker*"}
$myservice |format-list Name,Status,StartType


 function Get-USBInfo
 {
   param
     (
         $FriendlyName = '*'
           )
            
  Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBSTOR\*\*\' |
  Where-Object { $_.FriendlyName } |
  Where-Object { $_.FriendlyName -like $FriendlyName } |
  Select-Object -Property FriendlyName, Mfg |
  Sort-Object -Property FriendlyName
} 

# Get Firewall rules...
Get-NetFirewallRule -PolicyStore ActiveStore

# Using .Net Framework
$myObj = New-Object System.Net.WebClient
$myContent = $myObj.DownloadString("http://blogs.msdn.com/Powershell/rss.aspx")
$myContent.Substring(0,1000)

$myObj = New-Object System.Net.HttpWebRequest
$myObj.Address()

# Working with Active Directory
[ADSI] "WinNt://./Administrator" | fl *

# Working with COM objects
$firewall = New-Object -ComObject HnetCfg.FwMgr
$firewall.LocalPolicy.CurrentProfile

# Navigate the certificate store
Set-Location Cert:\CurrentUser\Root
Get-ChildItem

# & Use ampersand to run a command when in quotes
# & '.\Program with spaces.exe'

# Start a long running job
Start-Job { while($true) { Get-Random; Start-Sleep 5 } } -Name Sleeper
Receive-Job Sleeper
Get-Job
Remove-Job

get-command -verb Out*
get-command -noun *proces*

$servers = "mydc-01","myprint01","mymanage02"
$servers | foreach {
  $computername = $_
  #Write-Host "Processing $computername" -ForegroundColor green
  Try {
    $s = Get-Service -Name spooler -ComputerName $computername -ErrorAction Stop
    $Verified = $True
  }
  Catch {
    $Verified = $False
  }
  Finally {
    [pscustomobject]@{
      Computername = $Computername
      Service = "Spooler"
      Verified = $Verified
  }
 }
}

# Running Get-Service over a single remoting port and in parallel
Invoke-Command -scriptblock {
  Try {
    $s = Get-Service -Name spooler -ErrorAction Stop
    $Verified = $True
  }
  Catch {
    $Verified = $False
  }
  Finally {
    [pscustomobject]@{
      Service = "Spooler"
      Verified = $Verified
  }
}
}  -computer $servers | Select PSComputername,Service,Verified | sort Verified

# look at temp files older than 3 months 
$cutoff = (Get-Date).AddMonths(-3)
 
$space = Get-ChildItem "$env:temp" -Recurse -Force |
  Where-Object { $_.LastWriteTime -lt $cutoff } |
  Measure-Object -Property Length -Sum |
  Select-Object -ExpandProperty Sum
 
'Taken space: {0:n1} MB' -f ($space/1MB) 

##### look at temp files older than 3 months 


}