@echo off

REM Configure Windows firewall to allow network access to WinRM
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=Yes

REM Ensure the Administrator password never expires
wmic USERACCOUNT where "name='Administrator'" SET PasswordExpires=FALSE
