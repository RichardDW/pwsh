# Target SKU: '2016-Datacenter'

$locName = 'SouthCentralUS'

Get-AzVMImagePublisher -Location $locName | where-object {$_.PublisherName -like "*windows*"} | Format-Table -Property PublisherName, Location

$pubName = "MicrosoftWindowsServer"

Get-AzVMImageOffer -Location $locName -PublisherName $pubName | Format-Table -Property Offer, PublisherName, Location

$offerName = "WindowsServer"

Get-AzVMImageSku -Location $locName -PublisherName $pubName -Offer $offerName | Format-Table -Property Skus, Offer, PublisherName, Location

$skuName = "2016-Datacenter"

Get-AzVMImage -Location $locName -PublisherName $pubName -Skus $skuName -Offer $offerName