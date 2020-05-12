

Write-host "This is to try the invocation vairable" 
Write-Host "$($MyInvocation.InvocationName)" 
Write-Host "$($MyInvocation.MyCommand)" 

function Test-myVB {

[cmdletbinding()]
param()

Write-Output "This is for testing Verbosing"
Write-Verbose -Message " This is a verbose message"

}



# Test file is d:\tmp\testReplace.txt

# template csv file is d:\data\src\data\wordList.csv

$templateFile = "d:\data\src\data\wordList.csv"

$template = Import-Csv -Path $templateFile -Delimiter ","
$template.Old
$template.New
$stencil = Get-Content -Path $templateFile
$stencil2 = Get-Content -Path $templateFile -Raw


$myContent = Get-content -Path d:\tmp\testReplace.txt -Raw
foreach ($line in $myContent) {
  $line #-replace $template.Old , $template.New
}

ForEach ($line in $stencil){
  "Old value $line[0]", "New value $line[1]"
  #$myContent -replace "$line.Old", "$line.New"
}
$myContent