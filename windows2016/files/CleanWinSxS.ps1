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

# Clean WinSxS with the Deployment Image Servicing and Management (DISM) tool
#
# NOTE:
# There is a bug in Dism that prevents the cleanup operation from exiting
# cleanly on the first run. During the cleanup Dism removes a number of
# files it later tries to compress or process in some way. For example
# Dism deletes and then immediately tries to compress a backup file at:
# C:\Windows\Servicing\Sessions\Sessions.back.xml. Unsurprisingly this
# causes an '[HRESULT = 0x80070002 - ERROR_FILE_NOT_FOUND]' error.
# Since the process exits abnormally ($LASTEXITCODE = 2) it would be
# caught by Packer and the build would be stopped.
# The solution is to run the command a second time - this completes
# without error.
# For good measure we run Dism with the RestoreHealth option afterward
# to fix any possible errors. This is purely precautionary as manual runs
# with ScanHealth have shown that the component store has no errors or
# issues.
#
# Run #1: Will error due to bug
Write-Host '* Dism Run 1: This will error due to a bug (can be ignored)'
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
Write-Host ''
#
# Run #2: We haven't even started... and Windows is already broken :)
Write-Host '* Dism Run 2: This run will now complete sucessfully at 20%'
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
Write-Host ''
#
# Ensure any issues with the component store are repaired
Write-Host '* Now running Dism with RestoreHealth option (precaution only)'
Dism.exe /online /Cleanup-Image /RestoreHealth
Write-Host ''

Write-Host 'Complete'
