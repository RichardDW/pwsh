return "This is a walkthrough demo"

#demo optional regular expression matching

#region Example 1

Clear-Host
#You start with this
[regex]$p = "^\w+@\w+\.com"

$t0 = "ArtDeco@company.com"

$p.Match($t0)

#but this fails when you want it to match
$t1 = "jeff-hicks@company.com"
$p.Match($t1)

Clear-Host
#match with an optional -
$p = "^\w+(-\w+)?@\w*.com"
#now both match
$p.Match($t0).value
$p.Match($t1).value

#an alternative pattern
$p = "^\S+@\w*.com"
$t2 = "foo bar@company.com"
$t0,$t1,$t2 | where-object {$p.IsMatch($_) }

Clear-Host
#endregion

#region Example 2

[regex]$rx = "\.ps([md])?1$"

#do some pre-filtering before fine-tuning with the regular expression
#on the chance there might be a file like foo.psc1 which I don't want
Get-Childitem S:\*.ps* |
Where-Object {$rx.IsMatch($_.name)} | 
Group-Object -property extension |
Select-Object Name,Count,
@{Name="Size";Expression = {($_.group | Measure-Object -Property length -sum).sum}}

Clear-Host

#endregion