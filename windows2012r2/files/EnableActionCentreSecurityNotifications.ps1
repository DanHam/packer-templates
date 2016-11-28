# Re-enable Security and Maintenance notifications in Action Centre
#
# A previous script stops Security and Maintenance notifications from
# appearing in Action Centre. This prevents notifications relating to
# actions performed in the build process from being displayed in the
# final image.
# This script restores the default behaviour of displaying Security and
# Maintenance notifications

Write-Host 'Enabling Security and Maintenance notifications in Action Centre'

$RegKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\' +
          'Settings\Windows.SystemToast.SecurityAndMaintenance\'
$RegSetting = 'Enabled'

Set-ItemProperty -Path $RegKey -Name $RegSetting -Value '1' -Type DWORD -Force

Write-Host 'Complete'

# Allow time to view output before window is closed
Start-Sleep -Seconds 2
