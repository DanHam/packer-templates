# Remove unused Windows Features On Demand files
# See: https://technet.microsoft.com/en-us/library/jj127275.aspx
#
# Note:
# Installation of roles and features in the resultant image will require
# access to a specially configured remote share, installation media or
# Windows Update to proceed.

# The option of whether or not to remove Windows Feature on Demand files
# is configured from within the Packer template and exported as an
# environment variable
If ( $env:REMOVE_FEATURES_ON_DEMAND -ne $true ) {
    Write-Host 'Skipping removal of Windows Features on Demand files'
    Write-Host 'Exiting'
    exit
}

Write-Host 'Removing Windows Features on Demand files as requested'
Get-WindowsFeature |
? { $_.InstallState -eq 'Available' } |
% {
    Write-Host "* Removing Feature on Demand: $($_.DisplayName)"
    Uninstall-WindowsFeature -Name $($_.Name) -Remove | Out-Null
}

Write-Host 'Complete'
