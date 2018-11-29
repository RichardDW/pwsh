## Get the status of specific services running on DC's ####################################################
# List of domain controllers
# create a static list OR
$dcs = "mydc-01", "mydc-02", "mydc-03", "my-test-01"
# get list of Domain Controllers from AD
$dcs = (Get-Addomain).ReplicaDirectoryServers

# List of services to monitor
$svcs = "adws", "dns", "kdc", "netlogon", "zabbix agent"

# Sort Services per Domain Controller
Get-Service -name $svcs -ComputerName $dcs | Sort Machinename |
Format-Table -group @{Name="Computername";Expression={$_.Machinename.toUpper()}} -Property Name,Displayname,Status
# Sort Domain Controllers per Service
Get-Service -name $svcs -ComputerName $dcs | Sort Displayname |
Format-Table -group @{Name="Service";Expression={"$($_.Displayname) [$($_.name)]"}} -Property @{Name="Computername";Expression={$_.Machinename.toUpper()}},Status -AutoSize
# Now using WMI to show all services sorted by ComputerName
$filter = "Name = 'ADS' OR Name = 'DNS' OR Name = 'KDC' OR Name = 'NetLogon' OR Name = 'Zabbix Agent'"
Get-WmiObject -Class Win32_service -filter $filter -ComputerName $dcs |
Select PSComputername,Name,Displayname,State,StartMode | format-table -autosize
# Now get Services that are not running
$filter = "(Name = 'ADS' OR Name = 'DNS' OR Name = 'KDC' OR Name = 'NetLogon' OR Name = 'Zabbix Agent') AND State<>'Running'"
Get-WmiObject -Class Win32_service -filter $filter -ComputerName $dcs |
Select PSComputername,Name,Displayname,State,StartMode | format-table -autosize
# Same type of filtering with Get-Service, only filtering is now done at the client instead of at Remote Server
Get-Service -name $svcs -ComputerName $dcs | where {$_.Status -ne "running"} |
Select Machinename,Name,Displayname,Status | format-table -AutoSize

############ Get the status of specific services running on DC's ##############
