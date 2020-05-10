

Write-host "This is to try the invocation vairable" 
Write-Host "$($MyInvocation.InvocationName)" 
Write-Host "$($MyInvocation.MyCommand)" 

function Test-myVB {

[cmdletbinding()]
param()

Write-Output "This is for testing Verbosing"
Write-Verbose -Message " This is a verbose message"

}

Write-Output