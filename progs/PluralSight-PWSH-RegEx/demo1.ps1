return "This is a walkthrough demo"

#region optional captures

psedit .\demo-regex-optional.ps1

#endregion

#region named captures

psedit .\demo-regex-namedcaptures.ps1

#endregion

#region look around

psedit .\demo-regex-look.ps1

#endregion

#region scripting with regular expressions

#proof of concept
# use single quotes to define a literal string
# an alternate string to test with
# $t = '2019-08-31T13:42:11.102Z[00:006640:] Action 1545199 [Trace - Install Endpoint Certificate [Windows]]: executing: cmd /c cscript install-cert.vbs'

$t = '2019-08-30T19:56:18.104Z[00:018664:] Action 1539774 [Patch - Blacklist 7]: executing: cmd /c xcopy /y blacklist-7.xml ..\..\Patch\blacklists\configurations\'

[regex]$rx = "(?<Date>\d{4}.*Z).*Action\s(?<ActionID>\d+)\s+\[(?<=\[)(?<Activity>.*)(?=\])\]:\s+(?<Action>.*)"

$m = $rx.Matches($t)
#again, it is assumed you know your data and it is predictable
[pscustomobject]@{
    Computername = $env:Computername
    Date         = $m.groups[1].Value -as [datetime]
    ActionID     = $m.groups[2].value -as [Int32]
    Activity     = $m.groups[3].value
    Action       = $m.groups[4].value
}

Clear-Host

#endregion

#region process a file

$logdata = Get-Content .\samplelog.txt
$logdata.count
#file sample
$logdata[0..4]

[regex]$rx = "(?<Date>\d{4}.*Z).*Action\s(?<ActionID>\d+)\s+\[(?<=\[)(?<Activity>.*)(?=\])\]:\s+(?<Action>.*)"

#test with a subset
$groups = $rx.Matches($logdata[0]).groups
$groups

#get the value when you may not know the position.
# --> Group names are case sensitive
[pscustomobject]@{
    Computername = $env:Computername
    Date         = $groups[$rx.GroupNumberFromName("Date")].Value -as [DateTime]
    ActionID     = $groups[$rx.GroupNumberFromName("ActionID")].Value -as [Int32]
    Activity     = $groups[$rx.GroupNumberFromName("Activity")].Value
    Action       = $groups[$rx.GroupNumberFromName("Action")].Value
}

#do it for all lines in the log file
Clear-Host
$logobjects = foreach ($line in $logdata) {

    $groups = $rx.Matches($line).groups

    [pscustomobject]@{
        Computername = $env:Computername
        Date         = $groups[$rx.GroupNumberFromName("Date")].Value -as [DateTime]
        ActionID     = $groups[$rx.GroupNumberFromName("ActionID")].Value -as [Int32]
        Activity     = $groups[$rx.GroupNumberFromName("Activity")].Value
        Action       = $groups[$rx.GroupNumberFromName("Action")].Value
    }

} #foreach

$logobjects.count

#now you can use the data
$logobjects | Sort-Object ActionID, Date | Format-Table -group ActionID -Property Date, Activity, Action

$logobjects | Where-Object { $_.activity -match "Patch" } | Select-Object Date, Action

Clear-Host

#creating a function to do the work
Function Convert-PatchLog {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Specify the log file path", ValueFromPipeline)]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path
    )

    Begin {
        Write-Verbose "Starting $($myinvocation.MyCommand)"
        [regex]$rx = "(?<Date>\d{4}.*Z).*Action\s(?<ActionID>\d+)\s+\[(?<=\[)(?<Activity>.*)(?=\])\]:\s+(?<Action>.*)"
        Write-Verbose "Using regex $rx"
        $names = ($rx.GetGroupNames() | Select-Object -Skip 1 ) -join ","
        Write-Verbose "Using group names $names"
    } #begin
    Process {
        Write-Verbose "Processing data from $(Convert-Path $Path)"
`       $logdata = Get-Content -path $Path
        #make sure data matches the regular expression
        if ($rx.IsMatch($logdata[0])) {
            foreach ($line in $logdata) {
                Write-Verbose "Processing $line"
                $groups = $rx.Matches($line).groups

                #add a Category Property
                Switch -Regex ($groups[$rx.GroupNumberFromName("Activity")].Value) {
                    "^Patch" { $Category = "Patch" }
                    "^Deploy" { $Category = "Deploy" }
                    "^Distribute" { $Category = "Distribution" }
                    "^Trace" { $Category = "Trace" }
                    "^Update" { $Category = "Update" }
                    "Group" { $Category = "Group" }
                    Default { $Category = "Default" }
                }
                Write-Verbose "Adding category $Category"
                [pscustomobject]@{
                    PSTypeName   = "PatchLog"
                    Computername = $env:Computername
                    Date         = $groups[$rx.GroupNumberFromName("Date")].Value -as [DateTime]
                    ActionID     = $groups[$rx.GroupNumberFromName("ActionID")].Value -as [Int32]
                    Activity     = $groups[$rx.GroupNumberFromName("Activity")].Value
                    Action       = $groups[$rx.GroupNumberFromName("Action")].Value
                    Category     = $Category
                }

            } #foreach
            Write-Verbose "Processed $($logdata.count) lines of text"
        }
        else {
            Write-Warning "Data in $path does not appear to match expected patch information."
        }
    } #process
    End {
        Write-Verbose "Ending $($myinvocation.MyCommand)"
    } #end
}

Clear-Host

# help Convert-PatchLog -Parameter Path
$c = Convert-PatchLog -Path .\samplelog.txt -Verbose

#a sample of results
$c[0..4]
$c[0] | Get-Member

Get-ChildItem .\samplelog.txt | Convert-PatchLog | Sort-Object Category,Date | 
Format-Table -GroupBy Category -Property Computername,Date,ActionID,Activity,Action

#added error handling when there are no matches
Get-ChildItem .\demo1.ps1 | Convert-PatchLog -verbose

#endregion