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
[string] $srrFile = "C:\sra\SRR_Acc_List.txt"

# Executable to run from the SRA Toolkit
# prefect will get the files in SRA format
# fastq-dump will convert SRA file to FASTQ format
[string] $fileExe = "C:\sra\sratoolkit\bin\prefetch.exe"
[string] $maxDLsize = "999G"
[string] $ascpArg = "c:\Program Files (x86)\Aspera\Aspera Connect\bin\ascp.exe|c:\Program Files (x86)\Aspera\Aspera Connect\etc\asperaweb_id_dsa.openssh"

function GetDownload {            

   [cmdletbinding()]            
   param(            
      [parameter(valuefrompipelinebypropertyname=$true)]            
      [string]$ComputerName = $env:computername            
   )            
      
   begin {}            
   process {
      # get total number of items 
      [string] $total_lines = Get-Content $srrFile | Measure-Object –Line |Select-Object -ExpandProperty Lines

      [int] $processed_lines = 0
         
      #foreach($line in [System.IO.File]::ReadLines($srrFile))
      foreach($line in (Get-Content $srrFile)) {
         $processed_lines = $processed_lines + 1
         Write-Host "Now processing $processed_lines of $total_lines"   
         & $fileExe -X $maxDLsize -a $ascpArg $line
      }      
   }            
   end {}            
}

function CheckDownload {
   # Count no of lines in download file
   [string] $lines_infile_number = (Get-Content $srrFile | Measure-Object).Count
   [string] $lines_infile = Get-Content $srrFile |Sort-Object
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
      Compare-Object $lines_infile $lines_indir | Select-Object -ExpandProperty InputObject | Out-File "C:\sra\failed_downloads.txt"
   }
}

function Main {
   GetDownload
   CheckDownload  
}

Main
