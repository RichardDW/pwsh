#################################################################################

# get list with the requested downloads
# goto NCBI site with a project code; https://www.ncbi.nlm.nih.gov/sra/?term=PRJNA353001
# and select "Send results to Run Selector and download Accession List
$txtFile = "C:\sra\failed_downloads.txt"

# Executable to run
# prefect will get the files in SRA format
# fastq-dump will convert SRA file to FASTQ format
$fileExe = "C:\sra\sratoolkit\bin\prefetch.exe"

# get total number of items
$total_lines = Get-Content $txtFile | Measure-Object –Line |Select-Object -ExpandProperty Lines

$processed_lines = 0

foreach($line in [System.IO.File]::ReadLines($txtFile))
{
    $processed_lines = $processed_lines + 1
    Write-Host "Now processing $processed_lines of $total_lines"   
    & $fileExe -X 999G -a "C:\Users\User\AppData\Local\Programs\Aspera\Aspera Connect\bin\ascp.exe|C:\Users\User\AppData\Local\Programs\Aspera\Aspera Connect\etc\asperaweb_id_dsa.openssh" $line
	#& $fileExe -O E:\PRJNA397453 $line
}

# -a "C:\Users\User\AppData\Local\Programs\Aspera\Aspera Connect\bin\ascp.exe|C:\Users\User\AppData\Local\Programs\Aspera\Aspera Connect\etc\asperaweb_id_dsa.putty"

# get list with the requested downloads
# goto NCBI site with a project code; https://www.ncbi.nlm.nih.gov/sra/?term=PRJNA353001
# and select "Send results to Run Selector and download Accession List
$txtFile = "C:\sra\PRJNA397453_SRR_Acc_List.txt"

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
    Write-Host "Written a failed_downloads file in in to retrieve failed downloads"
    Compare-Object $lines_infile $lines_indir | Select-Object -ExpandProperty InputObject |Out-File "C:\sra\failed_downloads.txt"
    }
