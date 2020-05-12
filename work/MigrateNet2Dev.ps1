############################################################################################################################################################################################################
#          This script is build in 3 blocks.
#    Block 1: finds and extracts the Registry.pol files to Registry.txt (uses  LGPO: https://blogs.technet.microsoft.com/secguide/2016/01/21/lgpo-exe-local-group-policy-object-utility-v1-0/)
#    Block 2: finds all the files that need to be modified and change those according the migrationtable.csv
#    Block 3: LGPO creates back the Registry.pol files with LGPO
#
############################################################################################################################################################################################################

Set-location "D:\GPOTransfer\MigrationTable"

$ErrorActionPreference = 'SilentlyContinue'
$List = "D:\GPOTransfer\MigrationTable\MigrationTable.csv"
$Location = "D:\GPOTransfer\MigrationTable\PlaceGpoHere"
$ReplacementList = Import-Csv $List

############################################################################################################################################################################################################
#
# block 1
#
############################################################################################################################################################################################################

$polListIn = Get-ChildItem -Recurse -Include Registry.pol -Path $Location
ForEach ($polIn in $polListIn) {   

.\LGPO.exe /parse /m $polIn.FullName > (Join-Path $polIn.directory registry.txt);

}

############################################################################################################################################################################################################
#
# block 2
#
############################################################################################################################################################################################################

$dirlist = Get-ChildItem -Recurse -Include Groups.xml,Registry.xml,GptTmpl.inf,registry.txt -Path $Location
ForEach ( $dir in $dirlist ) {
    $Content = Get-Content -Path $dir.FullName
    foreach ($ReplacementItem in $ReplacementList)
    {
        $Content = $Content.Replace($ReplacementItem.OldValue, $ReplacementItem.NewValue)
    }
    Set-Content -Path $dir.FullName -Value $Content
}

############################################################################################################################################################################################################
#
# block 3
#
############################################################################################################################################################################################################

$polListOut = Get-ChildItem -Recurse -Include registry.txt -Path $Location

ForEach ($polOut in $polListOut) {   

.\LGPO.exe /r $polOut.FullName /w (Join-Path $polOut.directory registry.pol);

}
