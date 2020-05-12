# Get domain
$domain = 'eu.rabonet.com'
$subdom = ($domain.Substring(0,2)).ToUpper()
# Get OU

# Get all GPO's in rabonet.com
New-Variable -Name "AllGPOs$subdom"
$AllGPOsEU = Get-GPO -All -Domain $domain | Select-Object DisplayName -ExpandProperty DisplayName|Sort-Object

$AllGPOsEU = Get-GPO -All -Domain eu.rabonet.com | Select-Object DisplayName -ExpandProperty DisplayName|Sort-Object
$AllGPOsAM = Get-GPO -All -Domain am.rabonet.com | Select-Object DisplayName -ExpandProperty DisplayName|Sort-Object
$AllGPOsAP = Get-GPO -All -Domain ap.rabonet.com | Select-Object DisplayName -ExpandProperty DisplayName|Sort-Object
$AllGPOsOC = Get-GPO -All -Domain oc.rabonet.com | Select-Object DisplayName -ExpandProperty DisplayName|Sort-Object

# Get GPO's for each OU (Dev, Pat, Uat, Prod) in EU
$DevGPOsEU = $AllGPOsEU | Where-Object {$_ -match 'Dev-'}
$PatGPOsEU = $AllGPOsEU | Where-Object {$_ -match 'Pat-'}
$UatGPOsEU = $AllGPOsEU | Where-Object {$_ -match 'Uat-'}
$ProdGPOsEU = $AllGPOsEU | Where-Object {$_ -match 'Prod-' -and $_ -notmatch 'ri.fcp'}

# Get GPO's for each OU (Uat, Prod) in AM
$UatGPOsAM = $AllGPOsAM | Where-Object {$_ -match 'Uat-'}
$ProdGPOsAM = $AllGPOsAM | Where-Object {$_ -match 'Prod-' -and $_ -notmatch 'ri.fcp'}

# Get GPO's for each OU (Uat, Prod) in AP
$UatGPOsAP = $AllGPOsAP | Where-Object {$_ -match 'Uat-'}
$ProdGPOsAP = $AllGPOsAP | Where-Object {$_ -match 'Prod-' -and $_ -notmatch 'ri.fcp'}

# Get GPO's for each OU (Uat, Prod) in OC
$UatGPOsOC = $AllGPOsOC | Where-Object {$_ -match 'Uat-'}
$ProdGPOsOC = $AllGPOsOC | Where-Object {$_ -match 'Prod-' -and $_ -notmatch 'ri.fcp'}


# Get total for each  OU (Dev, Pat, Uat, Prod) in EU
$DevGPOsTotal = $DevGPOs|Measure-Object -Line|Select-Object -ExpandProperty Lines
$PatGPOsTotal = $PatGPOs|Measure-Object -Line|Select-Object -ExpandProperty Lines
$UatGPOsTotal = $UatGPOs|Measure-Object -Line|Select-Object -ExpandProperty Lines
$ProdGPOsTotal = $ProdGPOs|Measure-Object -Line|Select-Object -ExpandProperty Lines

# Output files for each  OU (Dev, Pat, Uat, Prod) in EU
$DevGPOsListEU = "c:\Temp\UnLinked_Dev_GPOsEU.txt"
$PatGPOsListEU = "c:\Temp\UnLinked_Pat_GPOsEU.txt"
$UatGPOsListEU = "c:\Temp\UnLinked_Uat_GPOsEU.txt"
$ProdGPOsListEU = "c:\Temp\UnLinked_Prod_GPOsEU.txt"
$AllGPOsListEU = "c:\Temp\UnLinked_All_GPOsEU.txt"

# Output files for each  OU (Uat, Prod) in AM
$UatGPOsListAM = "c:\Temp\UnLinked_Uat_GPOsAM.txt"
$ProdGPOsListAM = "c:\Temp\UnLinked_Prod_GPOsAM.txt"
$AllGPOsListAM = "c:\Temp\UnLinked_All_GPOsAM.txt"

# Output files for each  OU (Uat, Prod) in AP
$UatGPOsListAP = "c:\Temp\UnLinked_Uat_GPOsAP.txt"
$ProdGPOsListAP = "c:\Temp\UnLinked_Prod_GPOsAP.txt"
$AllGPOsListAP = "c:\Temp\UnLinked_All_GPOsAP.txt"

# Output files for each  OU (Uat, Prod) in OC
$UatGPOsListOC = "c:\Temp\UnLinked_Uat_GPOsOC.txt"
$ProdGPOsListOC = "c:\Temp\UnLinked_Prod_GPOsOC.txt"
$AllGPOsListOC = "c:\Temp\UnLinked_All_GPOsOC.txt"




#EU EU EU EU
# Get all GPO's without a link in Dev EU
Foreach ($gpo in $DevGPOsEU) {
   
    If ( Get-GPOReport -Name $gpo -Domain eu.rabonet.com -ReportType xml | Select-String -NotMatch "<LinksTo>" ) {$gpo | Out-File $DevGPOsListEU –Append; $gpo | Out-File $AllGPOsListEU –Append }
    }

# Get all GPO's without a link in Pat EU
Foreach ($gpo in $PatGPOsEU) {
   
    If ( Get-GPOReport -Name $gpo -Domain eu.rabonet.com -ReportType xml | Select-String -NotMatch "<LinksTo>" ) {$gpo | Out-File $PatGPOsListEU –Append; $gpo | Out-File $AllGPOsListEU –Append }
    }

# Get all GPO's without a link in Uat EU
Foreach ($gpo in $UatGPOsEU) {
   
    If ( Get-GPOReport -Name $gpo -Domain eu.rabonet.com -ReportType xml | Select-String -NotMatch "<LinksTo>" ) {$gpo | Out-File $UatGPOsListEU –Append; $gpo | Out-File $AllGPOsListEU –Append }
    }

# Get all GPO's without a link in Prod EU
Foreach ($gpo in $ProdGPOsEU) {
   
    If ( Get-GPOReport -Name $gpo -Domain eu.rabonet.com -ReportType xml | Select-String -NotMatch "<LinksTo>" ) {$gpo | Out-File $ProdGPOsListEU –Append; $gpo | Out-File $AllGPOsListEU –Append }
    }

#AM AM AM AM
# Get all GPO's without a link in Uat AM
Foreach ($gpo in $UatGPOsAM) {
   
    If ( Get-GPOReport -Name $gpo -Domain am.rabonet.com -ReportType xml | Select-String -NotMatch "<LinksTo>" ) {$gpo | Out-File $UatGPOsListAM –Append; $gpo | Out-File $AllGPOsListAM –Append }
    }

# Get all GPO's without a link in Prod AM
Foreach ($gpo in $ProdGPOsAM) {
   
    If ( Get-GPOReport -Name $gpo -Domain am.rabonet.com -ReportType xml | Select-String -NotMatch "<LinksTo>" ) {$gpo | Out-File $ProdGPOsListAM –Append; $gpo | Out-File $AllGPOsListAM –Append }
    }

#AP AP AP AP
# Get all GPO's without a link in Uat AP
Foreach ($gpo in $UatGPOsAP) {
   
    If ( Get-GPOReport -Name $gpo -Domain ap.rabonet.com -ReportType xml | Select-String -NotMatch "<LinksTo>" ) {$gpo | Out-File $UatGPOsListAP –Append; $gpo | Out-File $AllGPOsListAP –Append }
    }

# Get all GPO's without a link in Prod AP
Foreach ($gpo in $ProdGPOsAP) {
   
    If ( Get-GPOReport -Name $gpo -Domain ap.rabonet.com -ReportType xml | Select-String -NotMatch "<LinksTo>" ) {$gpo | Out-File $ProdGPOsListAP –Append; $gpo | Out-File $AllGPOsListAP –Append }
    }


#OC OC OC OC
# Get all GPO's without a link in Uat OC
Foreach ($gpo in $UatGPOsOC) {
   
    If ( Get-GPOReport -Name $gpo -Domain oc.rabonet.com -ReportType xml | Select-String -NotMatch "<LinksTo>" ) {$gpo | Out-File $UatGPOsListOC –Append; $gpo | Out-File $AllGPOsListOC –Append }
    }

# Get all GPO's without a link in Prod OC
Foreach ($gpo in $ProdGPOsOC) {
   
    If ( Get-GPOReport -Name $gpo -Domain oc.rabonet.com -ReportType xml | Select-String -NotMatch "<LinksTo>" ) {$gpo | Out-File $ProdGPOsListOC –Append; $gpo | Out-File $AllGPOsListOC –Append }
    }


# Get modification time from all GPO's
# Get WMI Filter if used
# backups to \\bxtv187010.rabonet.com\GPOTransfer_W10\BU_Obsolete_GPO

(Get-Content $DevGPOsListEU)

Foreach ($gpo in (Get-Content $UatGPOsListOC)) {

    Write-Host $gpo -ForegroundColor Cyan
    (Get-GPO -Name $gpo -Domain oc.rabonet.com).GetSecurityInfo() | Where-Object {($_.Permission -eq 'GpoApply') -or ($_.Permission -eq 'GpoRead')}

}

$DevGPOsEU
 (Get-Content $DevGPOsEU)

$mygpo = Get-GPO -Name Prod-Global-W10ScriptHardeningPilot -Domain eu.rabonet.com
$myGpoSec = $mygpo.GetSecurityInfo() | Where-Object {($_.Permission -eq 'GpoApply') -or ($_.Permission -eq 'GpoRead')}   #Trustee, Permission = GpoApply, GpoRead
$myGpoSec|Out-File -FilePath c:\temp\gposec.txt
$myGpoSec|export-csv -LiteralPath c:\temp\gposec.csv
$myGpoSec|Export-Clixml -literalpath c:\temp\gposec.xml
$myGpoSecXML = Import-Clixml -LiteralPath c:\temp\gposec.xml

# To load XML file use:
# Method 1
[System.Xml.XmlDocument]$xdoc = new-object System.Xml.XmlDocument
$xdoc.load('c:\temp\gposec.xml')
# Method 2
[xml]$xdoc2 = Get-Content 'c:\temp\gposec.xml'
# Method 3
$xdoc3 = [xml](Get-Content 'c:\temp\gposec.xml')

$xdoc3 | Select-Xml -XPath "//Props" 
|Select-Object -ExpandProperty "node"

$xdoc3.Objs.Obj.Props.Obj.Props.S |Out-GridView
# Get Security ID Name
$xdoc3.Objs.Obj[0].Props.Obj[0].Props.S[2]
# Security right
$xdoc3.Objs.Obj[0].Props.Obj[1]
# Get Security ID Name
$xdoc3.Objs.Obj[1].Props.Obj[0].Props.S[2]
# Security right
$xdoc3.Objs.Obj[1].Props.Obj[1]


$xml_refid = $xdoc.SelectNodes("/Obj/RefId")
foreach ($RefId in $xml_refid) {
  echo $RefId.Props
}


$xdoc.ChildNodes|Select-Object -ExpandProperty Obj

$xdoc.Objs.Obj| Select-Object 

# If Trustee == 'Authenticated Users' and Permission == 'GpoRead' --> Security Filtering
# Filter out where Trustee == 'ENTERPRISE DOMAIN CONTROLLERS'

Foreach ($trustee in $myGpoSec) {
    $trustee.Trustee, $trustee.Permission
    }

$mygpo|Out-GridView
$mygpo.WmiFilter
$mygpo.ModificationTime
