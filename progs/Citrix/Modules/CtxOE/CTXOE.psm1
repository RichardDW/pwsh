# General function for execution of the plugins. 
Function Invoke-CTXOEPlugin ([String]$PluginName, [System.Xml.XmlElement]$Params, [String]$Mode) {

    [String]$m_FunctionName = "Invoke-CTXOE$($PluginName)$($Mode.ToString())"

    # First test if the required plugin and function is available 
    If ($(Get-Command "$m_FunctionName" -Module CTXOEP_$($PluginName) -ErrorAction SilentlyContinue) -isnot [System.Management.Automation.FunctionInfo]) {
        Throw "Failed to load the required plugin or required function has not been implemented.
        Module: CTXOEP_$($PluginName)
        Function: $m_FunctionName"
    }

    If ($Params -isnot [Object]) {
        Throw "<params /> element is invalid for current entry. Review the definition XML file."
    }

    # Run the plugin with arguments
    & (Get-ChildItem "Function:$m_FunctionName") -Params $Params

}

# Test if registry key (Key + Name) has the required value (Value). Returns a dictionary with two values - [Bool]Result and [String]Details. 
Function Test-CTXOERegistryValue ([String]$Key, [String]$Name, [String]$Value) {
    $m_Value = Get-ItemProperty -Path Registry::$($Key) -Name $Name -ErrorAction SilentlyContinue;

    [Hashtable]$Return = @{}

    $Return.Result = $False

    If ($m_Value -isnot [System.Management.Automation.PSCustomObject]) {
        $Return.Details = "Registry key not configured"
        # If CTXOE_NoValue is specified, it is expected that value does not exists.
        If ($Value -eq "CTXOE_NoValue") {
            $Return.Result = $True;
        }
    } ElseIf ($m_value.$Name -ne $Value) {
        $Return.Details = "Different value ($($m_value.$($Name)) instead of $Value)"
    } Else {
        $Return.Result = $True
        $Return.Details = "Requested value $Value is configured"
    }
    Return $Return
}

# Set value of a specified registry key. Returns a dictionary with two values - [Bool]Result and [String]Details.
Function Set-CTXOERegistryValue ([String]$Key, [String]$Name, [String]$Value, [String]$ValueType) {
    # If parent registry key does not exists, create it
    If ($(Test-Path Registry::$Key) -ne $true) {New-Item Registry::$Key -Force | Out-Null}

    # Now change the value
    $m_ExistingValue = Get-ItemProperty -Path Registry::$Key -Name $Name -ErrorAction SilentlyContinue
    Try {
        If ($Value -eq "CTXOE_NoValue") {
            Remove-ItemProperty -Path Registry::$Key -Name $Name -Force -ErrorAction SilentlyContinue | Out-Null
        } Else {
            New-ItemProperty -Path Registry::$Key -Name $Name -PropertyType $ValueType -Value $Value -Force | Out-Null
        }
    } Catch {
        [Hashtable]$Return = @{"Result" = $False; "Details" = $($_.Exception.Message)}; 
        Return $Return; 
    }

    # Rerun the validation test again
    [Hashtable]$Return = Test-CTXOERegistryValue -Key $Key -Name $Name -Value $Value
    If ($m_ExistingValue -is [Object]) {
        $Return.OriginalValue = $m_ExistingValue.$Name
    } Else {
        $Return.OriginalValue = "CTXOE_NoValue"
    }

    Return $Return
}

Function ConvertTo-CTXOERollbackElement ([Xml.XmlElement]$Element) {
    # Convert the element to XmlDocument. 
    [Xml]$m_TempXmlDocument = New-Object Xml.XmlDocument

    # Change the <params /> (or <executeparams /> to <rollbackparams />. 
    [Xml.XmlElement]$m_TempRootElement = $m_TempXmlDocument.CreateElement("rollbackparams")
    $m_TempRootElement.InnerXml = $Element.InnerXml
    $m_TempXmlDocument.AppendChild($m_TempRootElement) | Out-Null

    # Return object
    Return $m_TempXmlDocument
}

Function New-CTXOEHistoryElement ([Xml.XmlElement]$Element, [Boolean]$SystemChanged, [DateTime]$StartTime, [Boolean]$Result, [String]$Details, [Xml.XmlDocument]$RollbackInstructions) {
    # Delete any previous <history /> from $Element
    If ($Element.History -is [Object]) {
        $Element.RemoveChild($Element.History) | Out-Null; 
    }

    # Get the parente XML document of the target element
    [Xml.XmlDocument]$SourceXML = $Element.OwnerDocument

    # Generate new temporary XML document. This is easiest way how to construct more complex XML structures with minimal performance impact. 
    [Xml]$m_TempXmlDoc = "<history><systemchanged>$([Int]$SystemChanged)</systemchanged><starttime>$($StartTime.ToString())</starttime><endtime>$([DateTime]::Now.ToString())</endtime><return><result>$([Int]$Result)</result><details>$Details</details></return></history>"

    # Import temporary XML document (standalone) as an XML element to our existing document
    $m_TempNode = $SourceXML.ImportNode($m_TempXmlDoc.DocumentElement, $true)
    $Element.AppendChild($m_TempNode) | Out-Null; 

    # If $RollbackInstructions is provided, save it as a <rollackparams /> element
    If ($RollbackInstructions -is [Object]) {
        $Element.Action.AppendChild($SourceXML.ImportNode($RollbackInstructions.DocumentElement, $true)) | Out-Null
    }
}
# SIG # Begin signature block
# MIIYRQYJKoZIhvcNAQcCoIIYNjCCGDICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDydonvopxCgNmnUw0C5bwf+r
# wl+gghMrMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
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
# KoZIhvcNAQkEMRYEFKTEIbb8swCwNxv7UKp318WeIn/9MGQGCisGAQQBgjcCAQwx
# VjBUoDiANgBDAGkAdAByAGkAeAAgAFMAdQBwAHAAbwByAHQAYQBiAGkAbABpAHQA
# eQAgAFQAbwBvAGwAc6EYgBZodHRwOi8vd3d3LmNpdHJpeC5jb20gMA0GCSqGSIb3
# DQEBAQUABIIBAKomik0uG+f3+cv3XdZFOv8G8Prpk9IIzGaMcOJGzjfeadYRFSVf
# Iz/SL0/3GfzbObe9LGdFxsfA6YXz/3j1GQ8xWFvrNi37n8u4P8ma5Dbh9xBrxPXu
# nV/l1cUpI4TIipYVkuylUME3IrV3XPVr5M3gk2dNHF/iTrthJXuI1jIufD1tjlIF
# ca2jW3o6dVZzm9pb8aGPPMy6BqasUsMGAgVD4+/FaXG77A6OXJJMJqNPXSyYKlyi
# wyo6MgKTp0LPQscQfLF+TRjv4/McN6dYz2RPD2RIcfZ2ZEZK8HME0mFd0aXpf/3W
# eS9k85Q2GYSWQYWu4Bdg/0zIyfuUrWAxBDuhggILMIICBwYJKoZIhvcNAQkGMYIB
# +DCCAfQCAQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29y
# cG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2Vydmlj
# ZXMgQ0EgLSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZI
# hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTgxMjE0MTYzNDEy
# WjAjBgkqhkiG9w0BCQQxFgQUhvjRBJ/Lqpbb83JL2nFG2qAB+JAwDQYJKoZIhvcN
# AQEBBQAEggEAg2AqS+JHO0pU40ZZyDoB0jy2rr4I1e9dzIsdg9tOSV8ermb6UNnH
# fzYJ4WBw6ZPY2HzWUCliK1FtHfVSflz+OTx4VnUPnKXRj6di/RxZqAa9qR3nK1Hi
# MZPMzuluTBxij8z9QCbfRQyXaYUE/B6P+E7kPEQAghc0TIFkE3onTieLqePHdp9T
# CPagk2qeSeJnaN9gi4WIyJJLCJ1zz2Zs/+zbtfUv+gYMjYg6kvl++cH44O55Snqg
# kllt3UWbUn1ohcJKtsIfenJSN+kavj4zqL47LBtlfCA0+1AV5maJJyOcA8x6FWr+
# 3GwEk0YnSoqHSazR9+AR/RQiAiLNc5xImA==
# SIG # End signature block
