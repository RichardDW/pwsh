# Ref: https://blog.kloud.com.au/2017/11/21/azure-application-security-groups/

$webAsg = New-AzApplicationSecurityGroup -ResourceGroupName AppGatewayWAF -Name webAsg -Location southcentralus

$sqlAsg = New-AzApplicationSecurityGroup -ResourceGroupName AppGatewayWAF -Name sqlAsg -Location southcentralus

$webRule = New-AzNetworkSecurityRuleConfig `
    -Name "AllowHttps" `
    -Access Allow `
    -Protocol Tcp `
    -Direction outbound `
    -Priority 1500 `
    -SourceApplicationSecurityGroupId $webAsg.id `
    -SourcePortRange * `
    -DestinationAddressPrefix VirtualNetwork `
    -DestinationPortRange 443

$sqlRule = New-AzNetworkSecurityRuleConfig `
    -Name "AllowSql" `
    -Access Allow `
    -Protocol Tcp `
    -Direction outbound `
    -Priority 1000 `
    -SourceApplicationSecurityGroupId $sqlAsg.id `
    -SourcePortRange * `
    -DestinationAddressPrefix VirtualNetwork `
    -DestinationPortRange 1433

$nsg = New-AzNetworkSecurityGroup -ResourceGroupName AppGatewayWAF -Location southcentralus -Name asgTestnsg -SecurityRules $webRule, $sqlRule

$vnet = Get-AzVirtualNetwork -Name MyVNet -ResourceGroupName AppGatewayWAF
Set-AzVirtualNetworkSubnetConfig -Name default -VirtualNetwork $vnet -NetworkSecurityGroupId $nsg.Id -AddressPrefix '10.0.0.0/16'
Set-AzVirtualNetwork -VirtualNetwork $vnet

$webNic = Get-AzNetworkInterface -Name vm1Nic -ResourceGroupName AppGatewayWAF
$webNic.IpConfigurations[0].ApplicationSecurityGroups = $webAsg
Set-AzNetworkInterface -NetworkInterface $webNic

$sqlNic = Get-AzNetworkInterface -Name vm2Nic -ResourceGroupName AppGatewayWAF
$sqlNic.IpConfigurations[0].ApplicationSecurityGroups = $sqlAsg
Set-AzNetworkInterface -NetworkInterface $sqlNic