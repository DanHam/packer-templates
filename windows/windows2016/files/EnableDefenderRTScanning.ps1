# Re-enable Windows Defender real-time protection
#
# When real-time protection is enabled extremely high memory usage and
# significant CPU usage occurs during upload of the guest virtualisation
# tools ISOs. On a host with 2 CPUs and 4GB or RAM, CPU utilisation is a
# steady 10-25% while memory usage grows linearly from approximately
# 500,000k to 3,500,000k. Essentially, the Antimalware Service executable
# (MsMpEng.exe) consumes all free memory within the guest.
# Clearly the above can cause memory pressure, not just within the guest,
# but within the build host as well. As such we temporarily disable
# Defenders real-time protection with a script executed in the Autoattend
# first logon scripts. This script re-enables the real-time monitoring at
# the end of the build.

Write-Host 'Re-enabling Defenders real-time monitoring'
Set-MpPreference -DisableRealtimeMonitoring $false
Write-Host 'Complete'
