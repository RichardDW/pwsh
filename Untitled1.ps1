$myCIM = Get-CimInstance -ClassName Win32_Product 
$myCIM | Where-Object Name -like "*Edge*"

# select from Win32Reg_AddRemovePrograms

# select from CIM_Datafile

Get-CimInstance -ClassName Win32Reg_AddRemovePrograms

Get-CimInstance -ClassName CIM_Datafile

Get-WmiObject -Class Win32Reg_AddRemovePrograms

Get-WmiObject -Class Win32_Product 

$itemCount = 50

Write-Output $itemcount