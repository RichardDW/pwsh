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
