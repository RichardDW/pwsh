return "This is a walkthrough demo file"

#region filtering with Like operators

Get-Content .\servers.txt
Get-Content .\servers.txt | Where-Object {$_ -like "*core*"}

Get-Process | Select-Object name,company

Get-Process | where-object {$_.company -AND $_.company -notlike "Mic*"} |
Group-Object -property Company -NoElement |
Sort-Object -Property Count -Descending

#endregion

#region matching

"10.11.12" -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
"10.11.121.130" -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
$matches

#case sensitivity
"jeff" -like "Je*"
"jeff" -clike "Je*"

"jeff" -notlike "JE*"
"jeff" -cnotlike "JE*"

"PowerShell 5.1" -Match "P*shell"
"PowerShell 5.1" -cMatch "P*shell"
"PowerShell 5.1" -cnotMatch "P*shell"

#pattern matching drift
"jeff@company.com" -match "\w+@\w*\.com"
$matches.0
"jeff@company.comm" -match "\w+@\w*\.com"
$matches.0
"jeff-foo@company.comm" -match "\w+@\w*\.com"
$matches.0

#avoid pattern matching drift
#you can use an anchor at the start
"jeff-foo@company.comm" -match "^\w+@\w*\.com"

#anchor at the end
"jeff@company.comm" -match "\w+@\w*\.com$"

#anchor both
"jeff@company.com" -match "^\w+@\w*\.com$"
$matches.0
"jeff-foo@company.com" -match "^\w+@\w*\.com$"

#one way to fix this pattern - you will learn other ways later
"jeff-foo@company.com" -match "^\w+-\w+@\w*\.com$"
"jeff-foo@company.com" -match "^\S+@\w*\.com$"

#endregion

#region validating patterns

Open-EditorFile .\Test-CompanyIP.ps1

#dot source the function
. .\Test-CompanyIP.ps1
Test-CompanyIP -IPAddress 10.100.1.2 -Verbose

#failed

#temporarily set error color to green to make it easier to see
$host.PrivateData.ErrorForegroundColor = "yellow"
Test-CompanyIP -IPAddress 11.100.1.2 -Verbose

#endregion

#region Switch -regex

<#
switch -Regex ($string) {

    "<pattern>" {
        #code
    }
    "<pattern>" {
        #code
    }
    Default {
        #code for no matches - optional
    }
}

#>

psedit .\serverbuild.ps1
#run the script
.\serverbuild.ps1

Clear-Host
#endregion

#region Select-String

Get-Content .\process-list.txt

Get-Content .\process-list.txt | Select-String -Pattern "Power*"

#searching files
Get-ChildItem trans* | Select-String "Set-Service"

help Select-String -Parameter list
Get-ChildItem trans* | Select-String "Set-Service" �list

#you can use any regular expression pattern - this is using some features we will cover later
Get-ChildItem trans* | Select-String "[Ss]et-\w+\s+(-)?[a-zA-Z]+.*"

#Select-String writes an object to the pipeline
Get-ChildItem trans* | Select-String "[Ss]et-\w+\s+(-)?[a-zA-Z]+.*" | Get-Member

$lines = (Get-ChildItem trans* | Select-String "[Ss]et-\w+\s+(-)?[a-zA-Z]+.*").line

#fine tune the search - get just the cmdlet name
$lines | Select-String "set-\w+" |select-object -expandproperty matches |
Select-Object -property Value -Unique

#an alternative
($lines | Select-String "set-\w+").matches | Select-Object -property Value -Unique

#context
Help Select-String -Parameter context

#get the line before and after the match
Get-ChildItem trans* | Select-String set-service -Context 1,1

#get the 4 lines after the match
Get-ChildItem trans*.txt | Select-String Set-Service -Context 0,4 |
Sort-object Filename |  Select-Object Filename,LineNumber,
@{Name="ContextResult";Expression = {
$(@"
$(($_.context.precontext | Out-String).trim())
$($_.line)
$(($_.context.postcontext | Out-String).trim())
"@).trim() }} | Format-List

#a function to simplify the process
psedit .\Show-Context.ps1
. .\Show-Context.ps1
help Show-Context
Get-ChildItem trans*.txt | Select-String set-service -context 0,2 | Show-Context -ContextOnly

#endregion