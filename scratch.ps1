Get-CimInstance

#region Log
Get-EventLog -LogName Security | Out-File c:\temp\events.log

$myContents = Get-Content c:\temp\events.log 
$myContents | Select-String -Pattern "Credential Manager" -NotMatch | Out-File c:\temp\events_filtered.log

Get-Content c:\temp\events.log | Where-Object {$_ -notmatch "Credential Manager"} | Set-Content c:\temp\out.txt 

$fullCSV = Import-CSV -Path 'C:\temp\2019 Script Audit Report Week 36.csv' -Delimiter ';'
$SortedHash = Import-CSV -Path 'C:\temp\2019 Script Audit Report Week 36.csv' -Delimiter ';' | Sort-Object -Property filehash

$GroupedHash = $SortedHash | Group-Object {$_.filehash}
$CountedHash = $GroupedHash | Sort-Object -Property Count
$SortnCountedHash = $CountedHash | Select-Object -Property Count, Name | Sort-Object -Property Name 
$SortnCountedHash 
#endregion


$UniqueHash = $fullCSV | Sort-Object -Property filehash -Unique | Export-Csv -Path 'C:\temp\2019 Script Audit Report Week 36- SORTED.csv'

#region CSV

$WeekReportPath = $WeekReportPath | Split-Path -Parent

foreach ($line in $SortnCountedHash) {
    Write-Output ("$line.count" + ";" + "$line.Name")
}

$fullCSV = Import-CSV -Path 'd:\temp\report.csv' -Delimiter ';' | Sort-Object -Property filehash
$grouped = $fullCSV | Group-Object {$_.filehash}
$grouped 
| Export-CSV -Path D:\temp\count.csv -Delimiter ';'
$grouped | Out-File -FilePath d:\temp\group.txt 
#endregion

$grouped | Select-Object {$_.Count}, {$_.Name}, {$_.Group} | Export-CSV -Path D:\temp\count.csv -Delimiter ';'

$uniqueSites = $fullCSV.Sitename | Sort-Object | Get-Unique

$WeekReportPath = $WeekReportPath | Split-Path -Parent

foreach ($key in $grouped.group.keys) {
  write-host $grouped.group[$key]
}