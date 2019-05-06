
# Measure the workflow execution time
Measure-Command -Expression { Test-WFConnection -Computers $computers }




$s =  Get-ADComputer -Filter 'Name -like "OPER*"' | Select -Property Name 
foreach ($item in $s)
{
Write-Host $item
Write-Host "-----------"
    
}
