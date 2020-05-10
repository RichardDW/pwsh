# Using external utilities

$d=driverquery /fo csv | ConvertFrom-Csv
$d | Where-Object {$_."Driver Type" -notmatch "Kernel"} |
Sort-Object @{expression={$_."Link date" -as [datetime]}} -desc |
Select-Object -First 10 -prop "Display Name","Driver Type","Link Date"

#requires -version 3.0
Function Get-NBTName {
  $data=nbtstat /n | Select-String "<" | where {$_ -notmatch "__MSBROWSE__"}
  #trim each line
  $lines=$data | ForEach-Object { $_.Line.Trim()}
  #split each line at the space into an array and add
  #each element to a hash table
  $lines | ForEach-Object {
    $temp=$_ -split "\s+"
    #create an object from the hash table
    [PSCustomObject]@{
    Name=$temp[0]
    NbtCode=$temp[1]
    Type=$temp[2]
    Status=$temp[3]
    }
  }
} #end function


#Requires -version 3.0
whoami /groups /fo list | Select -Skip 4 | Where-Object {$_} |
  foreach-object -Begin {$i=0; $hash=@{}} -Process {
    if ($i -ge 4) {
      #turn the hash table into an object
      [PSCustomObject]$hash
      $hash.Clear()
      $i=0
    }
    else {
      $data=$_ -split ":"
      $hash.Add($data[0].Replace(" ",""),$data[1].Trim())
      $i++
    }
  }

ping 127.0.0.1 -n 1

$pn = "-n 1"
$addr = "127.0.0.1"
Invoke-Expression "ping $addr $pn"