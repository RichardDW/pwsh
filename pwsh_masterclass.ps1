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


ipconfig | Select-String -pattern 192.168.2.10
