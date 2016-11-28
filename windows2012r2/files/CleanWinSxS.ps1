# Clean up the Windows Component Store (WinSxS folder)
#
# This script removes all superseded versions of updates and other
# components from the Windows Component Store

# The option of whether or not to run the clean up of WinSxS is configured
# from within the Packer template and exported as an environment variable
If ( $env:CLEAN_WINSXS -ne $true ) {
    Write-Host 'Skipping clean up of Windows Component Store as requested'
    Write-Host 'Exiting'
    exit
}

Write-Host 'Cleaning superseded components from the Windows Component Store'
Write-Host '* This operation will take some time to complete...'
Write-Host '  Note that there will be no indication of progress from DISM'

# Clean WinSxS with the Deployment Image Servicing and Management (DISM) tool
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

Write-Host 'Complete'
