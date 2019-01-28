# get list with the requested downloads
# goto NCBI site with a project code; https://www.ncbi.nlm.nih.gov/sra/?term=PRJNA353001
# and select "Send results to Run Selector and download Accession List
#$txtFile = "C:\sra\PRJNA353001_SRR_Acc_List.txt"
$txtFile = "C:\sra\failed_downloads.txt"

# Executable to run
# prefect will get the files in SRA format
# fastq-dump will convert SRA file to FASTQ format
$fileExe = "C:\sra\sratoolkit\bin\prefetch.exe"

# Files will be placed in C:\Users\User\ncbi\public\sra

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

