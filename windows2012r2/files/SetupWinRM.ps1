# Configure WinRM settings

Write-Host 'Configuring WinRM'

# Make 100% sure we prevent Packer from connecting to WinRM while we
# attempt to configure everything
Disable-NetFirewallRule -DisplayGroup 'Windows Remote Management'

Write-Host '* Setting the WinRM Service start up type to Automatic'
Set-Service -Name WinRM -StartupType Automatic

Write-Host '* Deleting any pre-existing listeners'
winrm delete winrm/config/listener?Address=*+Transport=HTTP  2>$Null
winrm delete winrm/config/listener?Address=*+Transport=HTTPS 2>$Null
Write-Host '* Creating an HTTP listener'
winrm create winrm/config/listener?Address=*+Transport=HTTP | Out-Null

# Service and client settings
Write-Host '* Allowing unencrypted traffic requests'
winrm set winrm/config/service '@{AllowUnencrypted="true"}' | Out-Null
Write-Host '* Allowing basic authentication for the WinRM service'
winrm set winrm/config/service/auth '@{Basic="true"}' | Out-Null
Write-Host '* Allowing basic authentication for WinRM clients'
winrm set winrm/config/client/auth '@{Basic="true"}' | Out-Null

# Adjust default quota management settings for remote shells
Write-Host '* Increasing limit on max memory allocatable to remote shells'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}' | Out-Null
Write-Host '* Increasing the max concurrent users who can open shells to 10'
winrm set winrm/config/winrs '@{MaxConcurrentUsers="10"}' | Out-Null

Write-Host '* Restarting the WinRM service'
Stop-Service -Name WinRM
Start-Service -Name WinRM

Write-Host '* Configuring UAC to allow privilege elevation in remote shells'
$Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$Setting = 'LocalAccountTokenFilterPolicy'
Set-ItemProperty -Path $Key -Name $Setting -Value 1 -Force

# Give WinRM time to become fully operational before allowing access
Start-Sleep -Seconds 3

Write-Host '* Configuring Windows firewall to allow access to WinRM'
(Get-NetFirewallRule -DisplayGroup 'Windows Remote Management').Name | % {
    Set-NetFirewallRule -Name $_ -Direction Inbound -Action Allow
}
Enable-NetFireWallRule -DisplayGroup 'Windows Remote Management'

Write-Host 'WinRM set-up complete'

# Allow time to view output before window is closed
Start-Sleep -Seconds 2
