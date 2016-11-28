# Configure Windows Update to receive updates from Microsoft Update servers

Write-Host 'Configuring Windows Updates'

# Set the ServiceID for the Microsoft Update Service
$MicrosoftUpdateServiceID = '7971f918-a847-4430-9279-4a52d1efe18d'
# Flag: 1 = Allow pending registration
#       2 = Allow online registration
#       7 = Register the service with Windows Updates
$AddServiceFlag = 7
$authorizationCabPath = ''

# Add and register the 'Microsoft Update Service' with Windows Update Agent
Write-Host '* Configuring Windows Update to connect to Microsoft Update servers'

$objServiceManager = New-Object -ComObject 'Microsoft.Update.ServiceManager'

# Add the 'Microsoft Update Service' to the Windows Update Service Manager
# and register the service with the Windows Update Agent. This will make
# 'Microsoft Updates' the default update service
$objService = $objServiceManager.AddService2($MicrosoftUpdateServiceID,$AddServiceFlag,$authorizationCabPath)

# Restart the Windows Update Service
Write-Host '* Restarting the Windows Update Service'
Stop-Service -Name wuauserv -Force
Start-Service -Name wuauserv

Write-Host 'Complete'

# Allow time to view output before window is closed
Start-Sleep -Seconds 2
