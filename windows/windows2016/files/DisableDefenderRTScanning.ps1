# Disable Windows Defender real-time protection
#
# When real-time protection is enabled extremely high memory usage and
# significant CPU usage occurs during upload of the guest virtualisation
# tools ISOs. On a host with 2 CPUs and 4GB or RAM, CPU utilisation is a
# steady 10-25% while memory usage grows linearly from approximately
# 500,000k to 3,500,000k. Essentially, the Antimalware Service executable
# (MsMpEng.exe) consumes all free memory within the guest.
# Clearly the above can cause memory pressure, not just within the guest,
# but within the build host as well. As such we temporarily disable
# Defenders real-time protection here. It is re-enabled with a script at
# the end of the build

Write-Host 'Disabling Defenders real-time monitoring during the build process'
Set-MpPreference -DisableRealtimeMonitoring $true
Write-Host 'Complete'

# Allow time to view output before window is closed
Start-Sleep -Seconds 2
