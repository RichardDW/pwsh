# Create full VM image

$vmName = 'myVM'
$rgName = 'myResourceGroup'
$location = 'EastUS'
$imageName = 'myImage'

Stop-AzVM -ResourceGroupName $rgName -Name $vmName -Force

Set-AzVm -ResourceGroupName $rgName -Name $vmName -Generalized

$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName

$image = New-AzImageConfig -Location $location -SourceVirtualMachineId $vm.ID

New-AzImage -Image $image -ImageName $imageName -ResourceGroupName $rgName

# Create an image from a snapshot

$rgName = 'myResourceGroup'
$location = 'EastUS'
$snapshotName = 'mySnapshot'
$imageName = 'myImage'

$snapshot = Get-AzSnapshot -ResourceGroupName $rgName -SnapshotName $snapshotName

$imageConfig = New-AzImageConfig -Location $location

$imageConfig = Set-AzImageOsDisk -Image $imageConfig -OsState Generalized -OsType Windows -SnapshotId $snapshot.Id

New-AzImage -ImageName $imageName -ResourceGroupName $rgName -Image $imageConfig






