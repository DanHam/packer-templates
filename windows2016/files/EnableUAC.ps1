# Ensure UAC is enabled

Write-Host 'Ensuring UAC is enabled'

# UAC is set to enabled when the registry setting has a value of 1
$RegKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$RegSetting = 'EnableLUA'

$CurrentValue = (Get-ItemPropertyValue -Path $RegKey -Name $RegSetting)

If ( $CurrentValue -ne 1 ) {
    Write-Host '* Re-enabling UAC as it is currently disabled'
    Set-ItemProperty -Path $RegKey -Name $RegSetting -Type DWORD -Value 1 -Force
    Write-Host '* WARNING: A reboot will be required to activate the setting'
}
elseif ( $CurrentValue -eq 1 )
{
    Write-Host '* UAC is currently enabled. No action required'
}

Write-Host 'Complete'
