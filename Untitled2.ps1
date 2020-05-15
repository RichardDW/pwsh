

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

$List = "d:\data\src\data\wordList.csv"
$ReplacementList = Import-Csv -Path $List -Delimiter ","
$Content = Get-content -Path d:\tmp\testReplace.txt
$Location = "d:\tmp"

$dirlist = Get-ChildItem -Recurse -Include Groups.xml,Registry.xml,GptTmpl.inf,registry.txt -Path $Location
ForEach ( $dir in $dirlist ) {
  write-host "Now processing $($dir.Fullname)"
  foreach ($ReplacementItem in $ReplacementList)
  {
    If ($Content = $Content.Replace($ReplacementItem.Old, $ReplacementItem.New)) {
      Write-Output "Now replacing $($ReplacementItem.Old)"
    }
  }
}

Set-Content -Path d:\tmp\testReplace.txt -Value $Content




$myContent = Get-content -Path d:\tmp\testReplace.txt -Raw
foreach ($line in $myContent) {
  $line #-replace $template.Old , $template.New
}

ForEach ($line in $stencil){
  "Old value $line[0]", "New value $line[1]"
  #$myContent -replace "$line.Old", "$line.New"
}
$myContent

$List = "D:\GPOTransfer\MigrationTable\MigrationTable.csv"
$Location = "D:\GPOTransfer\MigrationTable\PlaceGpoHere"
$ReplacementList = Import-Csv $List

foreach ($ReplacementItem in $ReplacementList)
  {
    $Content = $Content.Replace($ReplacementItem.OldValue, $ReplacementItem.NewValue)
  }

#--------

# template csv file is d:\data\src\data\wordList.csv
$Location = "D:\tmp"
$List = "d:\data\src\data\wordList.csv"
$ReplacementList = Import-Csv $List


$dirlist = Get-ChildItem -Recurse -Include Groups.xml,Registry.xml,GptTmpl.inf,registry.txt -Path $Location
ForEach ( $file in $dirlist ) {
    $Content = Get-Content -Path $file.FullName
    Write-Host "Now processing $($file.Fullname)" -ForegroundColor Yellow
    foreach ($ReplacementItem in $ReplacementList)
    {
        $Content = $Content.Replace($ReplacementItem.OldValue, $ReplacementItem.NewValue)
    }
    #Write-Output "$file.FullName, $Content"
    Set-Content -Path $file.FullName -Value $Content
}




################ ORIG ##############

#Set-location "D:\GPOTransfer\MigrationTable"

$ErrorActionPreference = 'SilentlyContinue'
$List = "D:\GPOTransfer\MigrationTable\MigrationTable.csv"
$Location = "D:\GPOTransfer\MigrationTable\PlaceGpoHere"
$ReplacementList = Import-Csv $List;


Get-ChildItem -Recurse -Include Groups.xml,Registry.xml,GptTmpl.inf,registry.txt -Path $Location | 
ForEach-Object {
    $Content = Get-Content -Path $_.FullName;
    foreach ($ReplacementItem in $ReplacementList)
    {
        $Content = $Content.Replace($ReplacementItem.OldValue, $ReplacementItem.NewValue)
    }
    Set-Content -Path $_.FullName -Value $Content
}
