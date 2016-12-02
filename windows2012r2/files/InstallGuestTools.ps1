# Install guest virtualisation tools

# Set paths to guest tools ISOs from exported environment variables
# configured in the packer template
$vboxga_iso = $env:VBOXGA_ISO_PATH
$vmware_iso = $env:VMTOOLS_ISO_PATH

# Enumerate the platform we are on
$platform = (Get-WmiObject -Class Win32_ComputerSystem).Manufacturer

if ($platform -like '*innotek*') {
    Write-Host 'Virtualbox platform detected'

    # Find the Guest Additions Installer
    [bool]$vboxga_installer_found = $false

    # Guest Additions can be uploaded or 'attached' via the optical drive
    if ($vboxga_iso -ne $null) {
        if (Test-Path -Path $vboxga_iso) {
            # Guest Additions were uploaded
            Write-Host "* Guest Additions ISO found at $vboxga_iso"
            # Mount the Guest Additions ISO
            Write-Host '* Mounting the ISO'
            Mount-DiskImage -ImagePath $vboxga_iso
        }
    }

    # If we have found and mounted the ISO or if we are checking whether
    # the Guest Additions have been 'attached' the same method can be
    # used to enumerate the drive letter and root and subsequently set the
    # path to the installer.
    # If we have found and mounted the ISO but fail to find the installer
    # it's possible the ISO is corrupt. Otherwise it's possible the ISO
    # has not been attached. It could also be possible in either case that
    # the name of the installer has been changed
    Get-Volume | % {
        if ( $($_.FileSystemLabel) -like 'VBOXADDITIONS*' ) {
            Write-Host "* Guest Additions in Volume $($_.DriveLetter)"
            $root = (Get-PSDrive -Name $($_.DriveLetter)).Root
            # Set the full path to the installer
            $installer = $root + 'VBoxWindowsAdditions.exe'
            if (Test-Path -Path $installer) {
                [bool]$vboxga_installer_found = $true
            }
        }
    }

    # Install the Guest Additions
    if ($vboxga_installer_found) {
        # Install the Oracle certificate so the vbox additions are trusted
        Write-Host '* Adding Oracle CA cert to Trusted Publisher store'
        certutil -addstore -f 'TrustedPublisher' A:\oracle.cer | Out-Null
        Write-Host '* Installing the Guest Additions'
        $parameters = '/S'
        Start-Process $installer $parameters -Wait
    } else {
        Write-Host '* WARNING: Failed to find Guest Additions installer'
    }

    # Regardless of whether the installer was actually found, If the Guest
    # Additions were uploaded and mounted we need to tidy up
    if ($vboxga_iso -ne $null) {
        if (Test-Path -Path $vboxga_iso) {
            if ( (Get-DiskImage -ImagePath $vboxga_iso).Attached ) {
                Write-Host '* Unmounting the Guest Additions ISO'
                Dismount-DiskImage -ImagePath $vboxga_iso
            }
            Write-Host '* Deleting uploaded Guest Additions ISO'
            Remove-Item $vboxga_iso
        }
    }

} elseif ($platform -like '*VMware*') {

    Write-Host 'VMware platform detected'

    if ($vmware_iso -ne $null) {
        if (Test-Path -Path $vmware_iso) {

            Write-Host "* VMware Tools ISO found at $vmware_iso"

            # Mount the VMware tools ISO and run the installer
            Write-Host '* Mounting the ISO and installing VMware Tools'
            Mount-DiskImage -ImagePath $vmware_iso
            $drive = (Get-DiskImage -ImagePath $vmware_iso | Get-Volume).Driveletter
            $root = (Get-PSDrive -Name $drive).Root
            $installer = $root + 'setup64.exe'
            $parameters = '/S /v "/qn REBOOT=R"'
            Start-Process $installer $parameters -Wait

            # Dismount and delete the ISO
            Dismount-DiskImage -ImagePath $vmware_iso
            Write-Host '* Deleting uploaded VMware tools ISO'
            Remove-Item $vmware_iso
        } else {
            Write-Host "* WARNING: VMware tools ISO not found: $vmware_iso"
        }
    } else {
        Write-Host "* WARNING: Path to uploaded ISO unknown: empty env var"
    }
} else {
    Write-Host "* WARNING: Unknown platform: $platform"
}

Write-Host 'Complete'
