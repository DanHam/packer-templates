@echo off
REM Packer shutdown script: Disable access to WinRM and sysprep the machine

REM When first booted the created image will run through the post sysprep
REM steps and apply the settings given in the unattend file. After this
REM initial boot and configuration step is complete the machine will reboot
REM to finalise the changes.
REM Connectivity to WinRM is disabled here to prevent Vagrant from connecting
REM to the instance until this initial boot and reboot cycle is complete.
REM Network access to WinRM is restored through commands stored in a
REM SetupComplete.cmd script. By design this script is run at the end of
REM Windows Setup but before the first logon screen is displayed.
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=No

REM Sysprep the machine
c:\windows\system32\sysprep\sysprep.exe /oobe /generalize /shutdown /quiet /unattend:A:\SysprepUnattend.xml
