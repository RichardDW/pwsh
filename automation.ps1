#region
#
# Create text array to use in reports
$reportHeader = @"
************************
***** Daily report *****
************************
"@

#
 $cutoffDate = (Get-Date).AddDays(-90).Date

 Get-ChildItem | Where-Object {$_.LastWriteTime -le $cutoffDate}


#endregion