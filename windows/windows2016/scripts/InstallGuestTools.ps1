# Install guest virtualisation tools

# Set path to guest tools ISOs from exported environment variables
# configured in the packer template
$vboxga_iso = $env:VBOXGA_ISO_PATH

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
# path to the installer and software signing certificates.
# If we have found and mounted the ISO but fail to find the installer
# or certificates it's possible the ISO is corrupt. Otherwise it's
# possible the ISO has not been attached. It could also be possible in
# either case that the name of the installer or certificate directory
# has been changed.
Get-Volume | % {
    if ( $($_.FileSystemLabel) -like 'VBox*' ) {
        Write-Host "* Guest Additions in Volume $($_.DriveLetter)"
        $root = (Get-PSDrive -Name $($_.DriveLetter)).Root
        # Set the full path to the installer
        $installer = $root + 'VBoxWindowsAdditions.exe'
        if (Test-Path -Path $installer) {
            [bool]$vboxga_installer_found = $true
        }
        # Set the full path to the software signing certificates
        $certdir = $root + 'cert'
        if (Test-Path -Path $certdir) {
            $certs = Get-ChildItem -Path $certdir -Recurse | where {
                $_.Extension -eq ".cer" } | % { $_.FullName }
            if ($certs) {
                [bool]$vboxga_certs_found = $true
            }
        }
    }
}

# Install the Guest Additions
if ($vboxga_installer_found -and $vboxga_certs_found) {
    # Install all the Oracle signing certificates. This will ensure
    # the vbox additions drivers and software are trusted and will
    # prevent errors in the silent install
    Write-Host '* Adding Oracle signing certs to Trusted Publisher store'
    foreach ($cert in $certs) {
        certutil -addstore -f 'TrustedPublisher' $cert | Out-Null
    }
    Write-Host '* Installing the Guest Additions'
    $parameters = '/l /S'
    Start-Process $installer $parameters -Wait
} else {
    Write-Host '* WARNING: Guest Additions installer or certs not found'
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

Write-Host 'Complete'
