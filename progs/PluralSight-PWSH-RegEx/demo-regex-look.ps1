return "This is a walkthrough demo"

# http://www.rexegg.com/regex-disambiguation.html#lookarounds
# http://www.rexegg.com/regex-lookarounds.html

Clear-Host
$t = "2019-06-21 17:12:31Z : 172.16.1.123 [ Begin process data ] stuff"

#look behind before the match
# (?<=REGEX-PATTERN)WHAT-YOU-REALLY-WANT-PATTERN

#I want the text between [ ]
$t -match "(?<=\[).*"
$matches

#look ahead before the match
# WHAT-YOU-REALLY-WANT-PATTERN(?=REGEX-PATTERN)
$t -match "(?<=\[).*(?=\])"
$matches.Values

#you might need to trim spaces
$matches.Values.trim()

Clear-Host
#revisit with named captures
$r = "(?<status>(?<=\[\s+).*(?=\s+\]))"
$t -match $r
$matches
$matches.status

Clear-Host

# a combination of named captures with look arounds
[regex]$rx = "(?<date>\d{4}-(\d{2}(-)?){2}\s(\d{2}(:)?){3}Z).*(?<ip>(?<=\s:\s)(\d{1,3}(\.)?){4}).*(?<status>(?<=\[\s).*(?=\s\]))"

$m = $rx.match($t)
$m.groups

#get named groups
$m.groups | where-object {$_.name -notmatch '\d+'} | 
foreach-object -Begin {$h = @{} } -process {$h.add($_.name,$_.value)} -end {
 $h
}

[pscustomobject]@{
    Date = $h.date -as [datetime]
    IPAddress = $h.ip -as [ipaddress]
    Status = $h.status 
}

Clear-Host