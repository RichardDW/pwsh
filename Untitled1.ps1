Param(
  [Parameter(Mandatory=$true)]
  [string]$gpoFullName,
  [string]$gpoCleanName = $gpoFullName.Split("-")[-1],
  [string]$Description = "Grants access to GPO: $gpoFullName",
  [ValidateSet("Standard","Extended","Test")]
  [Alias("CSVFile","CSVTemplate")]
  [string]$TemplateForm = "Standard"
)

$gpoFullName
write-host "\n"
$gpoCleanName
write-host "\n"
$Description
write-host "\n"
$csv
write-host "\n"

$csv = Switch ($TemplateForm)
   {
     Standard { 'TemplStnd.csv' }
     Extended { 'TemplExtd.csv' }
     Test     { 'TemplTest.csv' }
     }

$TemplateFile = "$PSScriptRoot\\$csv"
$TemplateFile

# Test if cvs file exists
If (-Not (Test-Path -Path $TemplateFile)) {
  Write-Error -Message "CSV file not found, try again"
  Exit
}

#Process CSV
$Template = Import-Csv -Path $TemplateFile -Delimiter ";"
$Template
