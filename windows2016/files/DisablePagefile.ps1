# Disable the Windows Pagefile
#
# Typically the Windows Pagefile can be a GB or greater in size. Disabling
# and removing the Pagefile during the build process can therefore help in
# reducing the resulting image size.
# While the image is stored without a Pagefile a later script ensures that
# the Pagefile is created and automatically managed by Windows when the
# image is booted for the first time.

Write-Host 'Temporarily disabling Pagefile use to minimise the image size'

# Disable automatic management of the Pagefile
$system = Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges
If ($system.AutomaticManagedPagefile) {
    Write-Host '* Disabling automatic management of the Pagefile'
    $system.AutomaticManagedPagefile = $False
    $system.Put() | Out-Null
    Write-Host '* Management of the Pagefile is now under manual control'
} Else {
    Write-Host '* Manual management of the Pagefile is already enabled'
}

# Now Pagefile management is under manual control, remove any existing
# Pagefile from Memory Management settings. This will ensure the Pagefile
# is not present on next boot.
$pagefile = Get-WmiObject -Class Win32_PageFileSetting
If ($pagefile) {
    Write-Host "* Deleting pagefile $($pagefile.Name) from Memory Management"
    $pagefile.Delete()
}

Write-Host 'Complete'

# Allow time to view output before window is closed
Start-Sleep -Seconds 2
