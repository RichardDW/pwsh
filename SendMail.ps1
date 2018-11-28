# With all the parameters
Send-MailMessage -From richard_dewolff@hotmail.com `
    -SmtpServer smtp.live.com `
    -UseSsl `
    -Port 587 `
    -Credential (Get-Credential richard_dewolff@hotmail.com) `
    -To richard.dewolff@gmail.com `
    -Subject " Hello from the demo" `
    -Body " This is a test from powershell with the send-mailmessage cmdlet.
    This is line 2
    This is line 3"


# Set some parameters as default

$PSDefaultParameterValues = @{
    "Send-MailMessage:From" = "richard_dewolff@hotmail.com";
    "Send-MailMessage:SmtpServer" =  "smtp.live.com";
    "Send-MailMessage:UseSSL" =  $true;
    "Send-MailMessage:Port" =  587;
    "Send-MailMessage:Credential" = (Get-Credential richard_dewolff@hotmail.com)
}

Send-MailMessage -To meisterburger@live.com -Subject "Hello from the demoworld" -Body "Just a test from the demo env"

# turn off the default parameters
$PSDefaultParameterValues["Disabled"] = $true

