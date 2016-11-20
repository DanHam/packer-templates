# Create the directory used to store the 'SetupComplete.cmd' script if
# required and copy the SetupComplete.cmd provided on the Packer floppy
# disk into place
#
# The SetupComplete.cmd script is run after Windows Setup completes just
# prior to diplay of the logon screen. The commands in the script re-enable
# access to WinRM so that Vagrant can connect to the instance. Access was
# previously disabled by the Packer shutdown script to prevent Vagrant
# prematurely connecting to the instance while it performed its first boot
# and reboot configuration and finalisation steps.
# In addition the script ensures the Administrator password never expires.

Write-Host 'Copying SetupComplete.cmd script into required location'

$SetupCompleteScript = 'A:\SetupComplete.cmd'
$SetupCompleteDir = 'C:\Windows\Setup\Scripts\'

if ((Test-Path -Path $SetupCompleteDir) -ne 'True') {
    Write-Host '* Creating Windows Setup Custom Script folder'
    New-Item -Path $SetupCompleteDir -ItemType Directory | Out-Null
}

Write-Host "* Copying: $SetupCompleteScript -> $SetupCompleteDir"
Copy-Item -Path $SetupCompleteScript -Destination $SetupCompleteDir -Force

Write-Host 'Complete'
