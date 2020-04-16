Return "This is a walkthrough demo"
<#
for more advanced and experienced PowerShell scripters, here is some code 
showing how you might use regular expressions with a PowerShell class
#>

#region An advanced technique using a PowerShell Class

#the class properties can be defined with the proper type
Class ActionItem {
    [string]$Computername
    [datetime]$Date
    [int32]$ActionID
    [string]$Activity
    [string]$Action

    #define a constructor
    ActionItem([string]$Computername, [datetime]$Date, [int32]$ActionID, [string]$Activity, [string]$Action) {
        $this.Computername = $Computername
        $this.Date = $Date
        $this.ActionID = $ActionID
        $this.Activity = $Activity
        $this.Action = $Action
    }

} #end class definition

#run lines 10-26 to load the class definition into PowerShell

#initialize a hashtable
$hash = [ordered]@{Computername = $env:Computername }

#the text to process
$t = '2019-08-30T19:56:18.104Z[00:018664:] Action 1539774 [Patch - Blacklist 7]: executing: cmd /c xcopy /y blacklist-7.xml ..\..\Patch\blacklists\configurations\'

$m = $rx.Matches($t)

for ($i = 1; $i -lt $m.groups.count; $i++) {
    $hash.Add($rx.GroupNameFromNumber($i), $m.groups[$i].Value)
}

#the class handles property types
#The hashtable keys need to be in the same order as the constructor
New-Object -TypeName Actionitem -ArgumentList $($hash.values)

Clear-Host

#endregion