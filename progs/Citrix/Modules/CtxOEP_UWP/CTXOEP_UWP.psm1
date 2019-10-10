If (-not $(Get-Module -ListAvailable -Name Appx)) {
    Write-Host "Universal Windows Applications are not available on this system" 
    Return
}

# Get-AppxProvisionedPackage is quite slow. Instead of constantly running it, we are using cache to store the current packages in memory. Cache can be invalidated by changing the value of CTXOEUWP_IsCacheValid to false, in which case it will be automatically reloaded. 
$CTXOEUWP_Cache = Get-AppxProvisionedPackage -online
$CTXOEUWP_IsCacheValid = $true;

# In Windows 10 build 1709, new argument has been added (-AllUsers). This check determines if this argument is supported by current operating system or not. 
$CTXOEUWP_AllUsersSupported = $(Get-Command Remove-AppxProvisionedPackage -ParameterName AllUsers -ErrorAction SilentlyContinue) -is [System.Management.Automation.CmdletInfo];
Write-Host "Removal of already provisioned applications supported: $CTXOEUWP_AllUsersSupported"

Function Get-CTXOEUWPApp {
    If ($CTXOEUWP_IsCacheValid -eq $false) {
        $CTXOEUWP_Cache = Get-AppxProvisionedPackage -online
    }

    Return $CTXOEUWP_Cache
}

Function Test-CTXOEUWPAppExist ([String]$Name) {
    Return $(Get-CTXOEUWPApp | Where-Object {$_.DisplayName -eq $Name}) -is [Microsoft.Dism.Commands.AppxPackageObject]
}

Function Invoke-CTXOEUWPExecute ([Xml.XmlElement]$Params) {
    [Boolean]$m_Exists = Test-CTXOEUWPAppExist -Name $Params.Name

    If (-not $m_Exists) {
        $Global:CTXOE_Result = $True
        $Global:CTXOE_Details = "UWP app is not installed"
        Return
    }

    $m_PackageFullName = Get-AppxProvisionedPackage -online | Where-Object {$_.DisplayName -eq $Params.Name} | Select-Object -ExpandProperty PackageName

    Try {
        If ($CTXOEUWP_AllUsersSupported) {
            Remove-AppxProvisionedPackage -PackageName $m_PackageFullName -Online -AllUsers | Out-Null
        } Else {
            Remove-AppxProvisionedPackage -PackageName $m_PackageFullName -Online | Out-Null
        }
    } Catch {
        $Global:CTXOE_Details = "Failed to remove UWP app with following error: $($_.Exception.Message)"; 
    }

    $CTXOEUWP_IsCacheValid = $false; 
    $Global:CTXOE_SystemChanged = $true;

    [Boolean]$m_Exists = Test-CTXOEUWPAppExist -Name $Params.Name

    $Global:CTXOE_Result = $m_Exists - 1

    If (-not $m_Exists) {
        $Global:CTXOE_Details = "UWP app has been removed"; 
    }

    Return
}

Function Invoke-CTXOEUWPAnalyze ([Xml.XmlElement]$Params) {
    [Boolean]$m_Exists = Test-CTXOEUWPAppExist -Name $Params.Name

    [Boolean]$Global:CTXOE_Result = $m_Exists - 1
    If ($m_Exists) {
        $Global:CTXOE_Details = "UWP app is installed"
    } Else {
        $Global:CTXOE_Details = "UWP app is not installed"
    }

    Return
}

Function Invoke-CTXOEUWPRollback ([Xml.XmlElement]$Params) {
    $Global:CTXOE_Result = $False
    $Global:CTXOE_Details = "UWP module does NOT support rollback. If you need to rollback the changes, re-install the application manually"
}
# SIG # Begin signature block
# MIIYRQYJKoZIhvcNAQcCoIIYNjCCGDICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUes1iLix3920tzmaMH0YCqfFd
# Fp+gghMrMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7VvlVAIMA0GCSqGSIb3DQEBCwUAMGUx
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9v
# dCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEwMjIxMjAwMDBaMHIxCzAJBgNVBAYT
# AlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
# dC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNp
# Z25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD407Mcfw4R
# r2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx6nadBS63j/qSQ8Cl+YnUNxnXtqrw
# nIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEjlpB3gvmhhCNmElQzUHSxKCa7JGnC
# wlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJNYBi+qsSyrnAxZjNxPqxwoqvOf+l8
# y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2DZDv5LVOpKnqagqrhPOsZ061xPeM
# 0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9hbFig3NBggfkOItqcyDQD2RzPJ6f
# pjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1Ud
# DwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDAzB5BggrBgEFBQcBAQRtMGsw
# JAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcw
# AoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElE
# Um9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDov
# L2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDBP
# BgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93
# d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgBhv1sAzAdBgNVHQ4EFgQUWsS5eyoK
# o6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8w
# DQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi0RXILHwlKXaoHV0cLToaxO8wYdd+
# C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6ljlriXiSBThCk7j9xjmMOE0ut119E
# efM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0kriTGxycqoSkoGjpxKAI8LpGjwCUR
# 4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/PQMtARKUT8OZkDCUIQjKyNookAv4v
# cn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d9gEgzpkxYz0IGhizgZtPxpMQBvwH
# gfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJmoecYpJpkUe8wggVaMIIEQqADAgEC
# AhAI4MABW9nbec0xTxAiIO6GMA0GCSqGSIb3DQEBCwUAMHIxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25p
# bmcgQ0EwHhcNMTgwOTE4MDAwMDAwWhcNMTkwOTI1MTIwMDAwWjCBljELMAkGA1UE
# BhMCVVMxEDAOBgNVBAgTB0Zsb3JpZGExFzAVBgNVBAcTDkZ0LiBMYXVkZXJkYWxl
# MR0wGwYDVQQKExRDaXRyaXggU3lzdGVtcywgSW5jLjEeMBwGA1UECxMVWGVuQXBw
# KFNlcnZlciBTSEEyNTYpMR0wGwYDVQQDExRDaXRyaXggU3lzdGVtcywgSW5jLjCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMp2P2PX+npQCZbC+oFqFdQZ
# qRWgD9Cy36G3Qeo/rpfwXrLgpMBq9MVzaJezxp0ZtXnDCWfN4nTay2NFT8FNVz+O
# 81+UZTPOfor/2sywMyLm/cwkPLHTfSsixEXhwhZtTM0PQK+4yMSCLiXK5vfcdgXV
# hOvbQGO5Pe+WVlsDKl/wqBoN8EKADhpE2IO734rMkptJS38p51PB0GerWMoy8y8l
# l6t4WLAurreiJkZNdwKaZqoeVOlRAeZY1pqlua5c4mvfmysNUoog+gXHwqA7Xzko
# xs0Rh+T/0YCnFWq+lSo55QHBl+J46YBMl47zEgqAf79JMg3X1sEBwUk7NIE+9NEC
# AwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nEDwGD5LfZldQ5YMB0G
# A1UdDgQWBBTPstFb6eXkhbO25/97NmbNDeRvhTAOBgNVHQ8BAf8EBAMCB4AwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYvaHR0cDovL2NybDMu
# ZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwNaAzoDGGL2h0dHA6
# Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMEwGA1Ud
# IARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRp
# Z2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcBAQR4MHYwJAYIKwYB
# BQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggrBgEFBQcwAoZCaHR0
# cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJRENv
# ZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggEB
# AO3AtSNW+NVwqEY4wHFD2TweH7BDzYqKof2cxEakTYkaD/cpywsV47ZkvaRNooOB
# C/5d+Xv+GzOB+Q+fQ8Wn7PQRPxSb+irnvYUhJ8B4BnvrFngD19P2PRz948Zwo2u5
# vQRnScBCbkGXlfrbjcryg69CFkWUQtIW76uDTrdLZ4vPZbEzJdXV28CGtjnhhgB7
# UHClutHq+DZ+1ptpjjnonLqI4IpDfo5XgRuZ5k5PVY9mRlU7QfHE5q4vCuSb6bTV
# zoIeay45wu4lVemjcFf95nOlvuap6/SambalLAemgOUzsvUOTviAJM7K9/pfIHOb
# 5eUA80pQZZZw4WStYhPZP7oxggSEMIIEgAIBATCBhjByMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29t
# MTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5n
# IENBAhAI4MABW9nbec0xTxAiIO6GMAkGBSsOAwIaBQCggcQwGQYJKoZIhvcNAQkD
# MQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJ
# KoZIhvcNAQkEMRYEFAqUWhwpe4WaG8gYnlTgivwZKSH1MGQGCisGAQQBgjcCAQwx
# VjBUoDiANgBDAGkAdAByAGkAeAAgAFMAdQBwAHAAbwByAHQAYQBiAGkAbABpAHQA
# eQAgAFQAbwBvAGwAc6EYgBZodHRwOi8vd3d3LmNpdHJpeC5jb20gMA0GCSqGSIb3
# DQEBAQUABIIBACiM7XUdRVZvy/2O32CH/mpR6rcAjxmFwuif6Yzu4b4gm9iHS6g5
# ufyRVB/xALHQlW2BQuEP2BQbqTgxvL1uiklGS+D8vSbPl816cLF0GBXZyWAa8pQ4
# UqiF9R5J7mIouJJnOTVM4D30jbbh24vFYHTorpih8Qgt1SOAEB2dGC8pzb2h3z1r
# JfaBoCvXGQv8EfOw3TDUIlFeGm5SKpZQy6BIiHeovGoE2kqx2ZbgiqMc9WoeXP2B
# ntptS8ahwcLVTM+uQLOJZguHNPW6m0kvYLN4GJ0yjoN0DQ5sWZK3g54r30kJ+lQa
# IO7LQhjXEqnhH3ZxxRM7dXZ19EuzEeojQ4ShggILMIICBwYJKoZIhvcNAQkGMYIB
# +DCCAfQCAQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29y
# cG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2Vydmlj
# ZXMgQ0EgLSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZI
# hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTgxMjE0MTYzNDEx
# WjAjBgkqhkiG9w0BCQQxFgQUMuyiCdAvtSF40IgloIR6aN26F1owDQYJKoZIhvcN
# AQEBBQAEggEAEVdJjZ5Ez0bOS2ukMXxOozBafATvsGJ36LLspjbwEIPkL1CVzOHF
# gZa1gceNeuyjk/e80Yjw4uznQ8kflyU+t3rPggm34E7LpIhMbEMnVpUXC7XT8bXc
# mxvRe+Ni7XHriQOes19gXjc8mmu5IKE9NSOjAX79hqmKG7Qcwi+KcKdoQ5xDxuGp
# q2yirKEtxWeenWSVVqDlj/VJai9N7N8PRGBP/vlRxe1QvFUPxcRd0H9qxRz5fBOV
# dETgtWOLAQHptzOM9BSrF1EaKxEE+IcyUQkJDd4bLKJgPRHFgehncJoxftqereC9
# RdXdKaB2ed153Vc9EPnPd8z95pZn6vHkvg==
# SIG # End signature block
