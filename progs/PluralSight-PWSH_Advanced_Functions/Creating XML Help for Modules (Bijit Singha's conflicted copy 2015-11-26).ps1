#region Create the MyModule module in the appropriate PSModulePath location

## Create the module folder
$modulesFolder = $env:PSModulePath.Split(';')[0]
mkdir "$modulesFolder\MyModule"

## Create a blank PSM1 file
$moduleFile = New-Item -Path "$modulesFolder\MyModule\MyModule.psm1"

## Copy/paste the same two functions previously used as a standalone script from earlier into the module
ise $moduleFile.FullName

## Verify the path to place the XML file in
$myModuleFolderPath = (Get-Module MyModule -ListAvailable).ModuleBase

## See what options you have for the language folder
([System.Globalization.Cultureinfo]::GetCultures('AllCultures')).Name

## Create the folder --we're using English
$languageFolder = mkdir "$myModuleFolderPath\en-US"

## Create a blank XML file in the language folder appropiately named
New-Item -Path "$($languageFolder.FullName)\MyModule.psm1-help.xml"

## Copy our prebuilt XML file into the language folder
## Notice .EXTERNALHELP is still needed. This is only needed for script modules (not manifest modules)
## .EXTERNALHELP is not needed if it's specifically named MyModule.psm1-help.xml

## Reload or create a new PowerShell session




#endregion


$env:PSModulePath

