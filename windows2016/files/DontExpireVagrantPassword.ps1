# Configure the Vagrant Users password to never expire
# Requires Powershell >= 5.1
#
If ( (Get-LocalUser -Name "vagrant" -ErrorAction SilentlyContinue).PasswordExpires ) {
    Write-Host 'Configuring the Vagrant users password to never expire'
    Set-LocalUser -Name 'vagrant' -PasswordNeverExpires $true
} else {
    Write-Host 'The Vagrant users password is set to never expire'
}