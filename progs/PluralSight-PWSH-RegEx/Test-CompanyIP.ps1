Function Test-CompanyIP {
    [cmdletbinding()]

    Param(
        [Parameter(Mandatory,HelpMessage = "Enter a company IPv4 address that starts with 10.")]
        [ValidatePattern("^10\.\d{1,3}\.\d{1,3}\.\d{1,3}$")]
        [string]$IPAddress
    )

    Write-Verbose "Testing $IPAddress"
    Write-Host "#Your code runs here" -ForegroundColor green

}