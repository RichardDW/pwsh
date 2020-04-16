Param([string[]]$names = (Get-Content .\Servers2.txt))

foreach ($servername in $names) {
    Write-Host "Processing $servername" -ForegroundColor Yellow
    Switch -Regex ($servername) {
        "^LON" { Write-Host "Setting up for London" -fore green }
        "^SFO" { Write-Host "Setting up for San Francisco" -fore green }
        "-MKT-" { Write-Host "Configuring Marketing" -fore cyan }
        "-MFG-" { Write-Host "Configuring Manufacturing" -fore cyan }
        "DC\d+$" { Write-Host "Installing as a domain controller" -fore Magenta }
        "FP\d+$" { Write-Host "Installing as a file&print server" -fore Magenta }
        Default { Write-Warning "Failed to process $servername" }
    }
}