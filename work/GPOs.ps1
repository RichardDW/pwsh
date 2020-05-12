# GPO Naming convention Windows 10
# MSFT-*  MS Baseline
# Dev-*
# Pat-*
# Uat-*
# Prod-*



get-gporeport -Name Dev-Global-CP-IE11 -Domain eu.rabonet.com -Path C:\Temp\gpo_Dev-Global-CP-IE11.html -ReportType Html
get-gporeport -Name Dev-Global-CP-IE11 -Domain eu.rabonet.com -Path C:\Temp\gpo_Dev-Global-CP-IE11.xml -ReportType Xml

get-gporeport -Name 'Dev-Global-W10 Rabo Delta 1803' -Domain eu.rabonet.com -Path C:\Temp\gpo_Dev-Global-W10_Rabo_Delta_1803.html -ReportType Html
get-gporeport -Name Dev-Global-W10ScriptHardeningPilot -Domain eu.rabonet.com -Path C:\Temp\gpo_Dev-Global-W10ScriptHardeningPilot.html -ReportType Html
get-gporeport -Name Dev-Global-W10ScriptHardeningPilot -Domain eu.rabonet.com -Path C:\Temp\gpo_Dev-Global-W10ScriptHardeningPilot.xml -ReportType Xml

Get-ADuser -Identity Wolffrn.eu -properties *

Get-ADGroupMember -Identity eu.mgt.GroupManagerScript.gs |ft 

Import-Module "C:\Program Files\Quest\GPOADmin\GPOADmin.psd1"

cd psroot:

Import-Module GroupPolicy

Get-GPO -All | Sort-Object displayname | Where-Object { If ( $_ | Get-GPOReport -ReportType XML | Select-String -NotMatch "<LinksTo>" ) {$_.DisplayName } }

Get-GPO -All | Sort-Object displayname | Where-Object { If ( $_ | Get-GPOReport -ReportType XML | Select-String -NotMatch "<LinksTo>" ) {$_.DisplayName } } | Out-File "c:\Temp\UnLinked_Dev_GPOs.txt" –Append

$mygpo = Get-GPO -Name Prod-Global-W10ScriptHardeningPilot -Domain eu.rabonet.com
$mygpo.GetSecurityInfo()  #Trustee, Permission = GpoApply, GpoRea
$mygpo|gm
$mygpo.WmiFilter
$mygpo.ModificationTime

$mygporep = Get-GPOReport -Name Prod-Global-W10ScriptHardeningPilot -ReportType xml
$mygporep|gm
$mygporep

Get-GPO -Name Prod-Global-W10ScriptHardeningPilot |fl *


$AllGPOs = Get-GPO -All | Select-Object DisplayName -ExpandProperty DisplayName|Sort-Object


