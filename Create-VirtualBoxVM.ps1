<#
 # This file is to create a Virtual Box machine from command line and put everything in the location required
 #
 # $machinetype         = Machine version type. Can be found from 'VBoxManage.exe list ostypes'
 # $memory              = Size in MB of the required mem (defaults to 1024 - 1GB)
 # hddgb                = size in GB of HDD (defaults to 30GB)
 # $path                = Location to save the HDD and the machine snapshots
 # $vboxmanage          = Location of the Oracle Virtual Box command line management tool
 # $networkadapter      = Name of the network adapter that will be used for bridged mode
 #
 # TODO
 # - Change Network to allow different settings
 #>
Param(

   [Parameter(Mandatory=$true)]

   [string]$machinetype,
   [int]$memory=1024,
   [int]$hddgb=32768,
   [string]$path="D:\VirtualMachines\",
   [string]$vmboxmanage="D:\Program Files\Oracle\VirtualBox",
   [string]$networkadapter="TP-LINK Wireless USB Adapter"

)

$currentlocation = Get-Location
Set-Location $vmboxmanage

if($hddgb -ne 32768)
{
    $hddgb = $hddgb*1024
}

$VM=$machinetype

# create the required folders
$vmpath = $path+$VM
If(!(test-path $vmpath))
{
      New-Item -ItemType Directory -Force -Path $vmpath
      New-Item -ItemType Directory -Force -Path $vmpath\Snapshots
}

.\vboxmanage.exe createhd --filename $vmpath\$VM.vdi --size $hddgb
.\vboxmanage.exe createvm --name $VM --ostype $VM --register

.\vboxmanage.exe storagectl $VM --name "SATA Controller" --add sata --controller IntelAHCI
.\vboxmanage.exe storageattach $VM --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $vmpath\$VM.vdi

.\vboxmanage.exe storagectl $VM --name "IDE Controller" --add ide
.\vboxmanage.exe storageattach $VM --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium d:\ISO\$VM.iso


.\vboxmanage.exe modifyvm $VM --ioapic on
.\vboxmanage.exe modifyvm $VM --boot1 dvd --boot2 disk --boot3 none --boot4 none
.\vboxmanage.exe modifyvm $VM --memory $memory --vram 128
.\vboxmanage.exe modifyvm $VM --snapshotfolder $vmpath\Snapshots
.\vboxmanage.exe modifyvm $VM --nic1 bridged --bridgeadapter1 $networkadapter

#VBoxHeadless -s $VM
#$vboxmanage storageattach $VM --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium none

Set-Location $currentlocation