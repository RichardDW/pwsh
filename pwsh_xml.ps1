[XML]$MyXMLVariable

$MyXMLVariable = Get-Content “C:Windowssystem32inetsrvconfigapplicationHost.config

[XML]$AppConfig = Get-Content –Path “C:WindowsSystem32inetsrvconfigApplicationHost.config”


# // = relative path
#  / = absolute path
$AppConfig | Select-Xml –Xpath “//modules”

$AppConfig | Select-Xml –Xpath “//modules” | Select-Object –ExpandProperty “node”

$ThisNode = $AppConfig | Select-Xml –Xpath “//modules” | Select-Object –ExpandProperty “node”

$thisNode | Select-Object –ExpandProperty ChildNodes

$thisNode.Add


$AppHost | Select-XML –Xpath “//*[@name=’StaticFileModule’]”

$AppHost | Select-XML –Xpath “//modules/*[@name=’StaticFileModule’]”

$AppHost | Select-XML –Xpath “//*[*/@name=’StaticFileModule’]”

$AppHost | Select-XML –Xpath “//*[*/*/@name=’StaticFileModule’]”



$computers = Get-Content S:\myservers.txt | Where { Test-WSMan $_ -ErrorAction SilentlyContinue }
 
$os = Get-CimInstance Win32_Operatingsystem -ComputerName $computers |
Select @{Name="Computername";Expression={$_.PSComputername}},InstallDate,
Caption,Version,OSArchitecture
 
$cs = Get-Ciminstance Win32_Computersystem -ComputerName $computers | 
Select PSComputername,TotalPhysicalMemory,HyperVisorPresent,NumberOfProcessors,
NumberofLogicalProcessors 
 
$services = Get-Ciminstance Win32_Service -ComputerName $computers |
Select PSComputername,Name,Displayname,StartMode,State,StartName

[xml]$Doc = New-Object System.Xml.XmlDocument

$dec = $Doc.CreateXmlDeclaration("1.0","UTF-8",$null)
$doc.AppendChild($dec)

#-----------

$text = @"
 
Server Inventory Report
Generated $(Get-Date)
v1.0
 
"@
#----------

$doc.AppendChild($doc.CreateComment($text))
	
$root = $doc.CreateNode("element","Computers",$null)

foreach ($computer in $Computers) {
 $c = $doc.CreateNode("element","Computer",$null)
 
$c.SetAttribute("Name",$computer)
$osnode = $doc.CreateNode("element","OperatingSystem",$null)
$data = $os.where({$_.computername -eq $Computer})

$e = $doc.CreateElement("Name")
$e.InnerText = $data.Caption
$osnode.AppendChild($e)

"Version","InstallDate","OSArchitecture" | foreach {
    $e = $doc.CreateElement($_)
    $e.InnerText = $data.$_
    $osnode.AppendChild($e)
 }
 
$c.AppendChild($osnode)



### standard XML setup

<?xml version="1.0" encoding="UTF-8"?>
<Root>
    <Node attribute1="value" attribute2="value">
        <Element>SomeValue</Element>
        <Element2>SomeOtherValue</Element2>
    </Node>
</Root>

###########  Test with bands.xml #####################

[xml]$bandData = Get-Content d:\data\src\data\bands.xml
 
$bands = foreach ($band in $bandData.Bands.band) {
 
    Write-Host "Converting $($band.Name.'#text')" -ForegroundColor Cyan
    [PSCustomObject]@{
        Name = $band.Name.'#text'
        Founded = $band.Name.Year
        Origin = $band.Name.City
        Lead = $band.Lead
        Members = $band.Members.member
    }
}