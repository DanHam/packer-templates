# Disable UAC so that shells are Admin shells by default. This allow
# automation of the Windows Update process across any required reboots

Write-Host 'Disabling UAC to give admin shell when automating update process'
Write-Host 'Note that UAC will be re-enabled later in the build process'

# UAC is set to disabled when the registry setting has a value of 0
$RegKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$RegSetting = 'EnableLUA'
Set-ItemProperty -Path $RegKey -Name $RegSetting -Type DWORD -Value 0 -Force

Write-Host 'Complete'

# Allow time to view output before window is closed
Start-Sleep -Seconds 2
