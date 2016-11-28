# Install guest virtualisation tools

# Set paths to guest tools ISOs from exported environment variables
# configured in the packer template
$vboxga_iso = $env:VBOXGA_ISO_PATH
$vmware_iso = $env:VMTOOLS_ISO_PATH

# Enumerate the platform we are on
$virt_platform = (Get-WmiObject -Class Win32_ComputerSystem).Manufacturer

if (($virt_platform -like '*innotek*') -and (Test-Path -Path $vboxga_iso))
{
    Write-Host 'Virtualbox platform detected and Guest Additions ISO found'

    # Install the Oracle certificate so the vbox additions are trusted
    Write-Host '* Adding Oracle CA cert to Trusted Publisher store'
    certutil -addstore -f 'TrustedPublisher' A:\oracle.cer | Out-Null

    # Mount the Guest Additions ISO and run the installer
    Write-Host '* Mounting the ISO and installing VirtualBox Guest Additions'
    Mount-DiskImage -ImagePath $vboxga_iso
    $drive = (Get-DiskImage -ImagePath $vboxga_iso | Get-Volume).Driveletter
    $installer = $drive + ':\VBoxWindowsAdditions.exe'
    $parameters = '/S'
    Start-Process $installer $parameters -Wait

    # Dismount and delete the ISO
    Dismount-DiskImage -ImagePath $vboxga_iso
    Write-Host '* Deleting uploaded guest additions ISO'
    Remove-Item $vboxga_iso
    Write-Host 'Complete'
}
elseif (($virt_platform -like '*VMware*') -and (Test-Path -Path $vmware_iso))
{
    Write-Host 'VMware platform detected and VMware Tools ISO found'

    # Mount the VMware tools ISO and run the installer
    Write-Host '* Mounting the ISO and installing VMware Tools'
    Mount-DiskImage -ImagePath $vmware_iso
    $drive = (Get-DiskImage -ImagePath $vmware_iso | Get-Volume).Driveletter
    $installer = $drive + ':\setup64.exe'
    $parameters = '/S /v "/qn REBOOT=R"'
    Start-Process $installer $parameters -Wait

    # Dismount and delete the ISO
    Dismount-DiskImage -ImagePath $vmware_iso
    Write-Host '* Deleting uploaded VMware tools ISO'
    Remove-Item $vmware_iso
    Write-Host 'Complete'
}
else
{
    Write-Host "WARNING: Virt platform not detected or no guest tools found"
}
