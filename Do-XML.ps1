# This is for testing xml
Get-Process | Export-Clixml -Path C:\tmp\proclist.xml

$mygpoOU = Import-clixml -Path D:\temp\GPO_OU.xml
$mygpoOU.GpoLinks

$mygpo = Import-Clixml -Path D:\temp\GPO_GP.xml
$mygpo

$myxml = Import-Clixml -Path D:\temp\GPO_GP.xml

(Get-Item C:\temp\test.txt).DirectoryName

$myxml.Owner


## Excel ######
$excel = New-Object -ComObject excel.application
$excel.Visible = $true

# Workbook is File, Worksheet is Tab within Workbook
$workbook = $excel.Workbooks.Add()
$mysheet01 = $workbook.Worksheets.Item(1)
$mysheet01.Name = 'My_01'

####
$path = "$env:USERPROFILE\desktop\HelloWorld.xlsx"
$Excel = New-Object -ComObject Excel.Application
$ExcelWorkBook = $Excel.Workbooks.Open($path)

$ExcelWorkSheet = $Excel.WorkSheets.item("sheet1")
$ExcelWorkSheet.activate()
$ExcelWorkSheet.Cells.Item(1,1) = 'Hello World'

$ExcelWorkBook.Save()
$ExcelWorkBook.Close()
$Excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
Stop-Process -Name EXCEL -Force