# Configure the Vagrant Users password to never expire
#
$VUser = Get-WmiObject -Class Win32_UserAccount -Filter 'name = "vagrant"'
If ( $VUser.PasswordExpires ) {
    Write-Host 'Configuring the Vagrant users password to never expire'
    $VUser |
    Set-WmiInstance -Argument @{PasswordExpires = 0} |
    Out-Null
} else {
    Write-Host 'The Vagrant users password is set to never expire'
}
