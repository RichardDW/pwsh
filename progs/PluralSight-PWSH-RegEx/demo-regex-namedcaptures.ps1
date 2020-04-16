return "This is a walkthrough demo"

#region start simple - build patterns for the different parts you want to match

$t = "2019-06-21 17:12:31Z : 172.16.1.123 [ Begin process data ]"

#date
$t -match "\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}Z"
#a more complex alternative
# $t -match "\d{4}(-\d{2}){2}\s(\d{2}(:)?){3}Z"
$matches

#ip
$t -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
#a more complex alternative
# $t -match "(\d{1,3}\.){3}\d{1,3}"

#activity
$t -match "\[.*\]"
$matches.0

Clear-Host

#endregion

#region creating named captures

# (?<capture-name>Your-Pattern)

#repeat to describe the entire string

[regex]$rx = '(?<date>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}Z)\s:\s(?<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s\[\s(?<status>.*)\]'
$rx.IsMatch($t)

$m = $rx.Matches($t)
$m
$m.groups
$m.groups | Select-Object -Skip 1 -Property Name, Value

$m.groups | Select-Object -Skip 1 | ForEach-Object -begin { $h = @{ } } -process {
    $h.Add($_.name, $_.value.trim())
} -end {
    #all properties are strings
    [pscustomobject]$h
}

#assumes you know the order of your pattern

$o = [pscustomobject]@{
    Date      = $m.groups[1].value -as [datetime]
    IPAddress = $m.groups[2].value -as [ipaddress]
    Status    = $m.groups[3].value
}

$o
#everything is properly typed
$o | Get-Member

Clear-Host

#endregion

#region a dynamic alternative

$t = "2019-06-21 17:12:31Z : 172.16.1.123 [ Begin process data ]"
#notice I proper cased named captures
[regex]$rx = '(?<Date>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}Z)\s:\s(?<IP>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s\[\s(?<Status>.*)\]'

$rx.GetGroupNames()
$rx.GetGroupNumbers()
$rx.GroupNameFromNumber(1)

$m = $rx.match($t)
$hash = @{}
for ($i = 1; $i -lt $m.groups.count; $i++) {
    $hash.Add($rx.GroupNameFromNumber($i), $m.groups[$i].Value)
}

$hash

#All properties will be strings
New-Object -TypeName PSObject -Property $hash

Clear-Host

#endregion

<#
For more experienced scripters, here is some code that will dynamically add type as well

$m = $rx.match($t)
$hash = @{}

#define a hashtable of property types. The keys match the named captures.
$typehash = @{Date=[datetime];IP=[IPAddress];Status = [string]}

for ($i = 1; $i -lt $m.groups.count; $i++) {
    $name = $rx.GroupNameFromNumber($i)
    #get the value and cast it as the correct type from $typehash
    $value =  $m.groups[$i].Value -as $typehash.$name
    $hash.Add($name,$value)
}
$n = New-Object -TypeName PSObject -Property $hash
$n | Get-Member

#>