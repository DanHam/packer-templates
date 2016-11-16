# Configure WinRM settings

Write-Host 'Configuring WinRM'

# Prevent Packer from connecting to WinRM while we configure the service
Set-NetFirewallRule -DisplayGroup 'Windows Remote Management' -Enabled False

# Configure the WinRM service to start automatically on boot
Write-Host '* Setting the WinRM Service start up type to Automatic'
Set-Service -Name WinRM -StartupType Automatic

# Create an HTTP listener
Write-Host '* Deleting any pre-existing listeners'
winrm delete winrm/config/listener?Address=*+Transport=HTTP  2>$Null
winrm delete winrm/config/listener?Address=*+Transport=HTTPS 2>$Null
Write-Host '* Creating an HTTP listener'
winrm create winrm/config/listener?Address=*+Transport=HTTP | Out-Null

# Service and client settings
#
# Allow the client computer to request unencrypted traffic
Write-Host '* Allowing unencrypted traffic requests'
winrm set winrm/config/service '@{AllowUnencrypted="true"}' | Out-Null
# Allow the WinRM service to use Basic authentication
Write-Host '* Allowing basic authentication for the WinRM service'
winrm set winrm/config/service/auth '@{Basic="true"}' | Out-Null
# Allow the client computer to use Basic authentication
Write-Host '* Allowing basic authentication for WinRM clients'
winrm set winrm/config/client/auth '@{Basic="true"}' | Out-Null

# Adjust default quota management settings for remote shells
#
# Increase the max amount of memory allocatable to a remote shell
Write-Host '* Increasing limit on max memory allocatable to remote shells'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}' | Out-Null
Write-Host '* Increasing the max concurrent users who can open shells to 30'
winrm set winrm/config/winrs '@{MaxConcurrentUsers="30"}' | Out-Null
Write-Host '* Increasing the max number of processes per shell to 30'
winrm set winrm/config/winrs '@{MaxProcessesPerShell="30"}' | Out-Null

# Restart the WinRM service post configuration changes
Write-Host '* Restarting the WinRM service'
Stop-Service -Name WinRM
Start-Service -Name WinRM

# Configure the Windows firewall to allow access to WinRM
Write-Host '* Configuring Windows firewall to allow access to WinRM'
(Get-NetFirewallRule -DisplayGroup 'Windows Remote Management').Name | % {
    Set-NetFirewallRule -Name $_ -Direction Inbound -Action Allow
}
# Re-enable the rule group
Set-NetFireWallRule -DisplayGroup 'Windows Remote Management' -Enabled True

# Enable Remote UAC via registry setting
Write-Host '* Enabling UAC for remote (WinRM) users'
$KeyStore = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$Key      = 'LocalAccountTokenFilterPolicy'
Set-ItemProperty -Path $KeyStore -Name $Key -Value 1

Write-Host 'WinRM set-up complete'
