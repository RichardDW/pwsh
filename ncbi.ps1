<#
.SYNOPSIS
   This program will read a text file with SRA numbers to download
   from the NCBI website https://www.ncbi.nlm.nih.gov/
.DESCRIPTION
   This program downloads SRA files from the NCBI website
   To get a file with the content to download goto NCBI site with a project code; 
   https://www.ncbi.nlm.nih.gov/sra/?term=PRJNA353001
   https://www.ncbi.nlm.nih.gov/sra/?term=PRJNA397453
   and select "Send results to Run Selector and download Accession List
   Files will, by default, be placed in C:\Users\<username>\ncbi\public\sra
   This can be changed by running the bin\vdb-config 
   #################################################################################
   Prerequisites:
   SRA Toolkit - https://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?view=software
   IBM Aspera Connect Client - https://downloads.asperasoft.com/connect2/
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>

# $srrFile contains the location of the the SRA Accession list
[string]$srrFile = "C:\sra\SRR_Acc_List.txt"
# Here the failed downloads will be wriiten for further processing
[string]$srrFailedFile = "C:\sra\SRR_FailedDL_List.txt"
# Executable to run from the SRA Toolkit
# prefetch will get the files in SRA format
[string]$toolExe = "C:\sra\sratoolkit\bin\prefetch.exe"
# maximum download size argument for prefetch, use max size
[string]$arg_maxDLsize = "999G"
# path to the ascp executable and keyfile to enable downloads via Aspera Connect (instead of http)
[string]$arg_ascp = "c:\Program Files (x86)\Aspera\Aspera Connect\bin\ascp.exe|c:\Program Files (x86)\Aspera\Aspera Connect\etc\asperaweb_id_dsa.openssh"
# Location for the downloaded SRA files.
# This can be set with vdb-config from the SRA Toolkit (/path/to/toolkit/bin)
[string]$sraDLlocation = "D:\ncbi\sra"

function GetDownload {            

   [cmdletbinding()]            
   param(            
   )
      
   begin {}            
   process {
      # get total number of items 
      [string] $total_dl = Get-Content $srrFile | Measure-Object –Line |Select-Object -ExpandProperty Lines

      [int] $processed_dl = 0
         
      #foreach($line in [System.IO.File]::ReadLines($srrFile))
      foreach($line in (Get-Content $srrFile)) {
         $processed_dl = $processed_dl + 1
         Write-Host ""
         Write-Host "Now processing $processed_dl of $total_dl"   
         & $toolExe -X $arg_maxDLsize -a $arg_ascp $line
      }      
   }            
   end {}            
}

function CheckDownload {
   # Count number of lines in download file
   [string] $lines_infile_number = (Get-Content $srrFile | Measure-Object).Count
   [string] $lines_infile = Get-Content $srrFile |Sort-Object
   # Remove .tmp and .lock files from the download directory
   Get-ChildItem -Path $sraDLlocation *.tmp | ForEach-Object { Remove-Item -Path $_.FullName }
   Get-ChildItem -Path $sraDLlocation *.lock | ForEach-Object { Remove-Item -Path $_.FullName }
   # retrieve directory list and count number of files
   $lines_indir_number = (Get-ChildItem -Path $sraDLlocation -File |Measure-Object).Count
   $lines_indir = Get-ChildItem -Path $sraDLlocation -File |Select-Object -ExpandProperty Basename |Sort-Object
   # if not equal sort both lists and print differences
   # check if numers are equal
   If ($lines_infile_number -eq $lines_indir_number) {
      Write-Host "Files are equal"
      # Remove failed downloads file
   }
   Else {
      Write-Host "Not equal!!, files download $lines_indir_number and files is list $lines_infile_number"
      Compare-Object $lines_infile $lines_indir | Select-Object -ExpandProperty InputObject | Out-File $srrFailedFile
      Write-Host "Written a failed_downloads file to $srrFailedFile "
   }
}

function Convert2Fastq {
   # fastq-dump will convert a (downloaded) SRA file to FASTQ format
   # --out-dir to set path for the converted files
   # fastq-dump uses the default path for reading SRA files
   # [string]$sraDLlocation = "D:\ncbi\sra"

}


function Main {
   GetDownload
   CheckDownload  
}

Main
