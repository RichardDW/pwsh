# Enter port for listening
param($address="Any", $port=514)

# open UDP socket
$endpoint = new-object System.Net.IPEndPoint([IPAddress]::$address, $port)
$udpclient = new-object System.Net.Sockets.UdpClient $port

# process incoming packets
while(true)
{
 if($udpclient.Available)
 {
  # analyze udp packet
  $udpmessage = $([Text.Encoding]::ASCII.GetString($udpclient.Receive[ref] $endpoint))
  Write-Host "$($endpoint.Address.IPAddressToString $udpmessage"

  # Create message with contents of UDP packet
  Toast -Silent -Text "$($endpoint.Address.IPAddressToString) reports:", $udpmessage
  }
  # Loop to keep cpu down
  Start-Sleep -s 1

}
  
