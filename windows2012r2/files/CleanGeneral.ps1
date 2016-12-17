# Clean temp files, logs, etc

# The option of whether or not to perform a general clean up of the
# Windows volume is configured from within the Packer template and
# exported as an environment variable
If ( $env:CLEAN_GENERAL -ne $true ) {
    Write-Host 'Skipping general clean up of Windows as requested'
    Write-Host 'Exiting'
    exit
}

Write-Host 'Performing general clean up of Windows as requested'

# Cleaning Windows Update files requires we stop the Windows Updates
# service
If ( (Get-Service wuauserv).Status -eq 'Running') {
    Write-Host '* Cleaning Windows Updates downloads so stopping Windows Update service'
    Stop-Service wuauserv -Force
    [bool]$WindowsUpdatesRunning = $true
}

# Cleaning the Windows Component store ManifestCache requires we shutdown
# the Trusted Installer service
If ( (Get-Service TrustedInstaller).Status -eq 'Running') {
    Write-Host '* Cleaning WinSxS ManifestCache so stopping Trusted Installer service'
    Stop-Service TrustedInstaller
    [bool]$TrustedInstallerRunning = $true
}

# Loop through items in the array and remove
@(
    "$env:localappdata\Temp\*",
    "$env:windir\Logs\*",
    "$env:windir\Panther\*",
    "$env:windir\Temp\*",
    "$env:windir\WinSxS\ManifestCache\*"
    "$env:windir\SoftwareDistribution\Download\*"
) | % {
    if(Test-Path $_) {
        Write-Host "* Removing $_"
        try {
            Takeown /d Y /R /f $_ | Out-Null
            Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
            Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
        } catch { $global:error.RemoveAt(0) }
    }
}

# Restart the Windows Updates service if it was previously running
if ( $WindowsUpdatesRunning ) {
    Write-Host '* Restarting Windows Updates service post clean'
    Start-Service wuauserv
}

# Restart the Trusted Installer service if it was previously running
if ( $TrustedInstallerRunning ) {
    Write-Host '* Restarting Trusted Installer service post clean'
    Start-Service TrustedInstaller
}

Write-Host 'Complete'
