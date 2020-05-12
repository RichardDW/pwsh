# Define variables
# Get domain
$domain = 'eu.rabonet.com'
$logpath = 'c:\temp'

#$AllGPOs = Get-GPO -All -Domain $domain | Select-Object DisplayName -ExpandProperty DisplayName|Sort-Object

# Define functions
function Get-AllGPOs {

[cmdletbinding()]
param(
[parameter(valuefrompipelinebypropertyname=$true)]
[string]$domain
)


begin{}
process {

Get-GPO -All -Domain $domain | Select-Object DisplayName -ExpandProperty DisplayName|Sort-Object | Out-File -FilePath "$logpath\\$domain.txt"

}

end{}

}


function Get-OU_GPOs




function Get-OU_Unlinked_GPOs

# Get all GPO's without a link in Dev
Foreach ($gpo in $DevGPOs) {
   
    If ( Get-GPOReport -Name $gpo -ReportType xml | Select-String -NotMatch "<LinksTo>" ) {$gpo | Out-File $DevGPOsList –Append; $gpo | Out-File $AllGPOsList –Append }
    }
