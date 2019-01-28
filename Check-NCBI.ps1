# get list with the requested downloads
# goto NCBI site with a project code; https://www.ncbi.nlm.nih.gov/sra/?term=PRJNA353001
# and select "Send results to Run Selector and download Accession List
$txtFile = "C:\sra\PRJNA353001_SRR_Acc_List.txt"

# count no of lines in download file
$lines_infile_number = (Get-Content $txtFile | Measure-Object).Count
$lines_infile = Get-Content $txtFile |Sort-Object
# retrieve directory list and count no of files
$lines_indir_number = (Get-ChildItem -Path E:\ncbi\public\sra -File |Measure-Object).Count
$lines_indir = Get-ChildItem -Path E:\ncbi\public\sra -File |Select-Object -ExpandProperty Basename |Sort-Object
# if not equal sort both lists and print differences
# check if numers are equal
If ($lines_infile_number -eq $lines_indir_number) {
    Write-Host "Files are equal"
    }
Else {
    Write-Host "Not equal!!, files download $lines_indir_number and files is list $lines_infile_number"
    Write-Host "Written a failed_downloads file in order to retrieve failed downloads"
    Compare-Object $lines_infile $lines_indir | Select-Object -ExpandProperty InputObject |Out-File "C:\sra\failed_downloads.txt"
    }


#=======================================================
