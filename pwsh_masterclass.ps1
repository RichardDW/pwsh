if (1 -eq 1) { exit }

notepad.exe

Get-Process |  Where-Object {$_.Name -eq "notepad"}
Get-Process |  Where-Object {$_.Name -eq "notepad"} | Stop-Process
(Get-Process | Where-Object {$_.Name -eq "notepad"}).Kill()
(Get-Process | Where-Object {$_.Name -eq "notepad"})
(Get-Process | Where-Object {$_.Name -eq "notepad"})

Get-Process -Name notepad

$myprocs = Get-Process
$myprocs[2]
$myprocs.GetType()
$myprocs.GetType().FullName

Get-Process | Select-Object -Property Name, @{name='procid';expression={$_.id}}

Get-Process | Where-Object {$_.Handles -gt 1000}
get-process | Where-Object Handles -gt 1000 | Sort-Object -Property Handles | Format-Table Name, Handles -AutoSize |Get-Member
# get process in gridview and kill the one's selected
Get-Process | Out-GridView -PassThru | Stop-Process

Get-Process |Export-Clixml D:\tmp\procs.xml

Get-Process -Name RzSynapse

ipconfig | Select-String -pattern 192

# Variables
$name = "hello"
$name.GetType()
[char]$mychar = 'a'
$number = [int]42



# date and time

# Define first and last days of last week
$s = get-date -hour 0 -minute 0 -second 0
$weekStartDate = $s.AddDays(-6-($s).DayOfWeek.value__)

$e = get-date -hour 23 -minute 59 -second 59
$weekEndDate = $e.AddDays(-($e).DayOfWeek.value__)
#

# CUSTOM DATE DEFINITIONS
## Define first and last day of the week
#$weekStartDate = (get-date "08-28-2019")
#$weekEndDate = (get-date "08-29-2019")
#

## Define yesterday and lastweek variables
$Yesterday   = (Get-Date).AddDays(-1)
$lastWeek    = (Get-Date).AddDays(-7)

## Get last weeks weeknumber & yearnumber
$weekNumber =  ([System.Globalization.DateTimeFormatInfo]::CurrentInfo.Calendar.GetWeekOfYear([datetime]::Now,0,0) - 1)
#([System.Globalization.DateTimeFormatInfo]::CurrentInfo.Calendar.GetWeekOfYear([datetime]::Now,0,0) - 1)
$yearNumber = (get-date).year

$today = Get-Date
$today | Select-Object -ExpandProperty DayOfWeek

[datetime]::ParseExact("10-26-2019","MM-dd-yyyy",[System.Globalization.CultureInfo]::InvariantCulture)
$christmas = [System.DateTime]"25 december 2019"
($christmas - $today).Days
$today.AddDays(-60)
$mya = New-Object System.Globalization.DateTimeFormatInfo
$mya.DayNames


# Custom objects

dir c:\temp -file |
Select-Object Name, LastWriteTime,
@{Name="Size";
Expression={$_.Length}},
@{Name="Age"; Expression={(Get-Date) - $_.lastwritetime}} |
Sort Age -Descending |
Select-Object -First 10

$f = dir c:\work -File
$n = Get-Date
foreach ($file in $f ) {
  $h=@{
    Name     = $file.Name
    Modified = $file.LastWriteTime
    Size     = Sfile.Length
    Age = $n - $file.LastWriteTime
  }
  New-Object psobject -Property $h
}

dir c:\work -file |
ForEach-Object {
  [PSCustomObject]@{
    Name = $_.Name
    Size = $_.Length
    Modified = $_.LastWriteTime
    Age = (Get-Date)-$_.LastWriteTime
  }
}

[math].GetMembers() | Select-Object Name, MemberType -Unique | Sort-Object MemberType, Name

## Try Catch

$servname = "bits"

Try {
  Get-Service -Name $servname -ErrorAction Stop
}

Catch {
  Write-Warning "Failed to get service from $computername.$($_.Exception.Message)"
}



Get-Process | Where-Object StartTime |
Select-Object Name, Id, @{Name='Run';Expression={(Get-Date) - $_.StartTime}} |
Sort-Object Run -Descending | Select-Object -First 5

Get-Process | Where-Object StartTime | foreach {
  [PSCustomObject]@{
    Name=$_.Name
    ID=$_.Id
    Run=((Get-Date) - $_.StartTime)
  }
} | Sort-Object Run -Descending |Select-Object -First 10





#region disk history
#params
Param(
  [string[]]$Computername = $env:COMPUTERNAME
)
# sample usage
# .\GetDiskHistory.ps1 -Computername Mars, Moon, Saturn
$Computername = "localhost","MARS"

# Path to csv file
$CSV = "d:\data\diskhist.csv"
Test-Path -Path $CSV

# initialize an empty array
$data = @()

# define a hashtable of paramaters to splat to CIM
$cimParams = @{
  Classname   = "Win32_LogicalDisk"
  Filter      = "drivetype = 3"
  ErrorAction = "Stop"
}

Write-Host "Getting disk information for following computers: $Computername" -ForegroundColor Blue
foreach ($computer in $Computername) {
  Write-Host "Getting disk information from $computer." -ForegroundColor Cyan
  # update the hashtable on the fly
  $cimParams.Computername = $computer
  Try {
    $disks = Get-CimInstance @cimParams

    $data += $disks |
      Select-Object @{Name = "Computername"; Expression = {$_.SystemName}},
    DeviceID, Size, Freespace,
    @{Name = "PctFree"; Expression = { ($_.Freespace / $_.Size) * 100} },
    @{Name = "Date"; Expression = {Get-Date}}

  } # try
  Catch {
    Write-Warning "Failed to get disk data from $($computer.toUpper()). $($_.Exception.message)"
  } #catch
} #foreach

#only export if there is something in $data
if ($data) {
  $data | Export-Csv -Path $csv -Append -NoTypeInformation
  Write-Host "Disk report complete. See $CSV." -ForegroundColor Green

}
else {
  Write-Host "No disk data found." -ForegroundColor Yellow
}

#endregion disk history
