param (
    [string]$LDAPFilter,
    [string]$SearchBase="dc=eu,DC=rabonet,DC=com",
    [string]$Identity,
    [string]$ObjectClass="User",
    [string]$Action="test"
)



# - LDAPFilter  ="name=Veenstrar*"
# - SearchBase  ="dc=eu,DC=rabonet,DC=com"
# - ObjectClass ="User|computer|csv"
# - Identity       ="eu.mgt.GroupManagerScript.gs"
# - Action      = "{filename.}csv|Add|Remove"
# csv action = Action;Samaccountname;ObjectClass


$global:FolderToRead = "D:\GroupManager"
$global:logFile = $FolderToRead + "\log\FindComputers.log"
$global:Action = $Action.ToLower()
$global:ObjectClass=$ObjectClass.toLower()


function main() {
    log ("LDAPFilter    = " + $LDAPFilter)
    log ("SearchBase    = " + $SearchBase)
    log ("Action        = " + $Action)
    log ("logFile       = " + $logFile)


    if ($action -ne "remove") {
        if ($ObjectClass -eq "computer") {
            Log ("start seaching for computers $LDAPFilter")
            $result=Get-ADComputer -LDAPFilter "($LDAPFilter)" -SearchBase $SearchBase | Select-Object Samaccountname, ObjectClass
        }
        elseif ($ObjectClass -eq "user") {
            Log ("start seaching for Users $LDAPFilter")
            $result=Get-Aduser  -LDAPFilter "($LDAPFilter)" -SearchBase $SearchBase | Select-Object Samaccountname, ObjectClass
        }elseif ($ObjectClass -like "*.csv") {
            Log ("start action from CSV with name $ObjectClass")
            $result = import-csv "$FolderToRead\$ObjectClass" -Delimiter ";"
        }
    }else{
        $result=Get-ADGroupMember -Identity $Identity | where-object Samaccountname -Like $LDAPFilter |Select-Object Samaccountname
    }

    if ($result) {
        foreach ($item in $result) {
            # Log ("Found $($item.ObjectClass) with SamAccountname $($item.Samaccountname)")
            if ($action -eq "add")               {Add-ToAdGroup -Identity $Identity -SamAccountName $item.Samaccountname}
            elseif ($action -eq "remove")        {Remove-FromAdGroup  -Identity $Identity -SamAccountName $item.Samaccountname}
            else {log("Simulate : Adding $($item.Samaccountname) to $($Identity)")}
        }
    }


    #CleanUp
    if ($ObjectClass -like "*.csv") { rename-item -path "$FolderToRead\$ObjectClass" -NewName "$ObjectClass.Done" }


}


function Add-ToAdGroup($Identity, $SamAccountName) {
    log("Start adding $SamAccountName to $Identity")
    $AllReadymember = Get-ADGroupMember -Identity $Identity | Where-Object samaccountname -EQ $SamAccountName
    if ($AllReadymember) {
        log("Object $SamAccountName is already a member of $Identity")
    }else{
        add-ADGroupMember -Identity $Identity -Members $item.Samaccountname  -Confirm:$False
        Log ("Object $Samaccountname added to $Identity")
    }
}

function Remove-FromAdGroup($Identity, $SamAccountName) {
    log("Start removing $SamAccountName from $Identity")
    $AllReadymember = Get-ADGroupMember -Identity $Identity | Where-Object samaccountname -EQ $SamAccountName
    if ($AllReadymember) {
        log("Object $SamAccountName will be remove from $Identity")
        remove-ADGroupMember -Identity $Identity -Members $item.Samaccountname -Confirm:$False
    }else{
        Log ("Object $Samaccountname is not a member of $Identity")
    }
}



Function Log($logText){
    Try       {

        "[" + (Get-Date -format s) + "] [" + $scriptName + " " + $Version + "]" + "[" + ((Get-PSCallStack)[1].Command) +  "] " + $logText
        if ($logfile) {
            "[" + (Get-Date -format s) + "] [" + $scriptName + " " + $Version + "]" + "[" + ((Get-PSCallStack)[1].Command) + "] " + $logText|Out-File -Append -FilePath $logFile
        }
    }
    Catch{Write-Warning "Unable to write to log location $logFile (107) | $logText"}
}

main
