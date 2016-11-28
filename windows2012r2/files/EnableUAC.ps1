# Ensure UAC is enabled

Write-Host 'Ensuring UAC is enabled'

# UAC is set to enabled when the registry setting has a value of 1
$Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$Setting = 'EnableLUA'

$CurrentValue = (Get-ItemProperty -Path $Key -Name $Setting).$Setting

If ( $CurrentValue -ne 1 ) {
    Write-Host '* Re-enabling UAC as it is currently disabled'
    Set-ItemProperty -Path $Key -Name $Setting -Type DWORD -Value 1 -Force
    Write-Host '* WARNING: A reboot will be required to activate UAC'
}
elseif ( $CurrentValue -eq 1 )
{
    Write-Host '* UAC is currently enabled. No action required'
}

Write-Host 'Complete'
