# Parameters

# Options for the New-ADGroup
# -Name ri.gpo.W10ScriptHardeningExclude.us
# -Name eu.gpo.W10ScriptHardeningExclude.gs
# -Name eu.gpo.W10ScriptHardeningExclude.ls # Not member of .us group

# -GroupCategory Security
# -GroupScope Universal,Global,DomainLocal
## -DisplayName "RODC Administrators"
# -Description "Grants access to GPO: $GPO"
# -Path "OU=Application,OU=Groups,DC=rabonet,DC=com"
# -Path "OU=Application,OU=Groups,DC=eu,DC=rabonet,DC=com"

# Attributes
# cn = eu.gpo.W10ScriptHardeningPilot.gs
# description = Grant Access to xxx-Global-W10ScriptHardeningPilot
# distinguishedName = CN=eu.gpo.W10ScriptHardeningPilot.gs,OU=Application,OU=Groups,DC=eu,DC=rabonet,DC=com
# member = multi-valued (name, Container, Distinguished Name/ SID)
# name = eu.gpo.W10ScriptHardeningPilot.gs
# sAMAccountName = eu.gpo.W10ScriptHardeningPilot.gs
# Canonical name of object: eu.rabonet.com/Groups/Application/eu.gpo.W10ScriptHardeningPilot.gs

# Server BSTS111035.rabonet.com
# Server BSTS111031.eu.rabonet.com
# Server BXTS111134.am.rabonet.com
# Server BXTS111132.ap.rabonet.com
# Server BXTS111133.oc.rabonet.com

# Add-AdGroupMember

Param(
    [string]$gpoFullName,
    [string]$gpoCleanName
    # add GPO Clean Name
)

$gpoFullName = "Dev-Global-W10FirewallPoC"
$Description = "Grants access to GPO: $gpoFullName"

# If gpoCleanName not entered extract from gpoFullName
$gpoCleanName = $gpoFullName.Split("-")[-1]

$csv = "C:\Temp\SecGroupTemplate.csv"

#Process CSV
$Template = Import-Csv -Path $csv -Delimiter ";"


#Create AD Group


#Add AD Security group to other AD Group

