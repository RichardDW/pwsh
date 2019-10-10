# In order to support both Windows 7 and Windows 10, Get-ScheduledTask cannot be used. Original code was using schtasks, but since it's language specific, it had to be replaced with COM object Schedule.Service. 
$CTXOESchTasks_COMSchedule = New-Object –ComObject ("Schedule.Service")
$CTXOESchTasks_COMSchedule.Connect("localhost")

# Function to return all subfolders for scheduled tasks
Function Get-CTXOESchTasksSubfolders ($Folder) {
    [Array]$m_Subfolders = @()
    
    If ($Folder.Path -eq "\") {$m_Subfolders += $Folder}
    
    ForEach ($m_Folder in  $Folder.GetFolders(1)) {
        $m_Subfolders += $m_Folder;
        ForEach ($m_Subfolder in $(Get-CTXOESchTasksSubfolders -Folder $m_Folder)) {
            $m_Subfolders += $m_Subfolder;
        }
    }
    Return $m_Subfolders;
}

# function to return all scheduled tasks
Function Get-CTXOESchTasksTasks () {
    [Array]$m_Tasks = @()
    ForEach ($m_Subfolder in Get-CTXOESchTasksSubfolders -Folder $CTXOESchTasks_COMSchedule.GetFolder("\")) {
        $m_Tasks += $m_Subfolder.GetTasks(1);
    }
    Return $m_Tasks;
}

# Generate cache of all scheduled tasks
$CTXOESchTasks_Cache = Get-CTXOESchTasksTasks;
$CTXOESchTasks_IsCacheValid = $true;

# Check if leading and trailing "\" are available, if not append and return modified string
Function Test-CTXOESchTasksBackslashes ([string]$Path) {
    If ($Path -notlike "\*") {$Path = "\$Path"}

    If ($Path -notlike "*\") {$Path = "$Path\"}

    Return $Path
}

# Check if scheduled task exists
Function Test-CTXOESchTasksExist ([String]$Path) {
    Return $($CTXOESchTasks_Cache | Where-Object {$_.Path -eq "$Path"}) -is [Object]
}

# Check if scheduled task is enabled or disabled. Return $False for disabled, $True for enabled.
Function Test-CTXOESchTasksState ([String]$Path) {
    If ($CTXOESchTasks_IsCacheValid -eq $false) {$CTXOESchTasks_Cache = Get-CTXOESchTasksTasks};    
    Return [Boolean]$($CTXOESchTasks_Cache | Where-Object {$_.Path -eq $Path} | Select-Object -ExpandProperty Enabled)
}

Function Invoke-CTXOESchTasksExecuteInternal ([Xml.XmlElement]$Params, [Boolean]$RollbackSupported = $False) {


    [String]$m_Name = $Params.Name
    [String]$m_Path = Test-CTXOESchTasksBackslashes -Path $Params.Path
    [String]$m_State = $Params.Value
    [String]$m_FullPath = "$m_Path$m_Name"

    If ($m_State -ne "Disabled" -and $m_State -ne "Enabled") {Throw "Requested state is $m_State, which is not disabled or enabled"}

    [Boolean]$m_Exists = Test-CTXOESchTasksExist -Path $m_FullPath

    # If scheduled task does not exist, return $True if goal was to disable it, otherwise return $False
    If ($m_Exists -eq $False) {
        $Global:CTXOE_Result = $m_State -eq "Disabled"
        $Global:CTXOE_Details = "Scheduled task does not exist"
        Return
    }

    [Boolean]$m_CurrentState = Test-CTXOESchTasksState -Path $m_FullPath
    [Boolean]$m_DesiredState = $m_State -ne "Disabled"

    If ($m_DesiredState -eq $m_CurrentState) {
        $Global:CTXOE_Result = $True
        $Global:CTXOE_Details = "Scheduled Task already $($m_State)"
        Return
    } Else {

        $CTXOESchTasks_IsCacheValid = $false;
        [String]$m_RollbackState = ""

        If ($m_State -eq "Disabled") {
            schtasks /change /tn "$m_FullPath" /disable | Out-Null
            $CTXOESchTasks_IsCacheValid = $False;
            $m_RollbackState = "Enabled";
        } Else {
            schtasks /change /tn "$m_FullPath" /enable | Out-Null
            $CTXOESchTasks_IsCacheValid = $False;
            $m_RollbackState = "Disabled"
        }

        [Boolean]$m_CurrentState = Test-CTXOESchTasksState -Path $m_FullPath
    
        If ($m_DesiredState -eq $m_CurrentState) {
            $Global:CTXOE_Result = $True
            $Global:CTXOE_Details = "Scheduled Task has been $($m_State)"

            # System has been changed. Report it and generate a rollback element.
            $Global:CTXOE_SystemChanged = $true;
            If ($RollbackSupported) {
                [Xml.XmlDocument]$m_RollbackElement = CTXOE\ConvertTo-CTXOERollbackElement -Element $Params
                $m_RollbackElement.rollbackparams.value = $m_RollbackState
                $Global:CTXOE_ChangeRollbackParams = $m_RollbackElement
            }

            Return
        } Else {
            $Global:CTXOE_Result = $False
            $Global:CTXOE_Details = "Failed to set $($m_Name) to $($m_State) state"
            Return
        }
    }
    Return
}

Function Invoke-CTXOESchTasksAnalyze ([Xml.XmlElement]$Params) {

    [String]$m_Name = $Params.Name
    [String]$m_Path = Test-CTXOESchTasksBackslashes -Path $Params.Path
    [String]$m_State = $Params.Value
    [String]$m_FullPath = "$m_Path$m_Name"

    # If scheduled task does not exist, return $True if goal was to disable it, otherwise return $False
    If ($(Test-CTXOESchTasksExist -Path $m_FullPath) -eq $False) {
        $Global:CTXOE_Result = $m_State -eq "Disabled"
        $Global:CTXOE_Details = "Scheduled task does not exist"
        Return
    }

    [Boolean]$m_CurrentState = Test-CTXOESchTasksState -Path $m_FullPath

    If ($m_State -eq "Disabled" -and $m_CurrentState -eq $False) {
        $Global:CTXOE_Result = $True
        $Global:CTXOE_Details = "Scheduled Task is disabled"
    } ElseIf ($m_State -ne "Disabled" -and $m_CurrentState -ne $False) {
        $Global:CTXOE_Result = $True
        $Global:CTXOE_Details = "Scheduled Task is enabled"
    } Else {
        $Global:CTXOE_Result = $False
        $Global:CTXOE_Details = "Scheduled Task is not in $($m_State) state"
    }

    Return
}

Function Invoke-CTXOESchTasksExecute ([Xml.XmlElement]$Params) {
    Invoke-CTXOESchTasksExecuteInternal -Params $Params -RollbackSupported $true
}

Function Invoke-CTXOESchTasksRollback ([Xml.XmlElement]$Params) {
    Invoke-CTXOESchTasksExecuteInternal -Params $Params -RollbackSupported $false
}
