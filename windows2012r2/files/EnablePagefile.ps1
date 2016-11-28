# Re-enable the Windows Pagefile
#
# Typically the Windows Pagefile can be a GB or greater in size. Disabling
# and removing the Pagefile during the build process can therefore help in
# reducing the resulting image size.
# An earlier script should have disabled use of the Pagefile. This script
# re-enables it and places control of the Pagefile back under automatic
# control. Since a reboot is required for Windows to actually create and
# start using the Pagefile, the actual image produced by Packer will be
# without a Pagefile and will therefore be slightly reduced in size.
# However, on next boot the Pagefile will be present again within the image.

Write-Host 'Re-enabling auto management of the Pagefile for resultant image'

# Re-enable automatic management of the Pagefile
$system = Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges
If (($system.AutomaticManagedPagefile) -ne $true) {
    Write-Host '* Enabling automatic management of the Pagefile'
    $system.AutomaticManagedPagefile = $true
    $system.Put() | Out-Null
    Write-Host '* A Pagefile will be automatically created on next boot'
} Else {
    Write-Host '* Automatic management of the Pagefile is already enabled'
}

Write-Host 'Complete'