param($global:RestartRequired=0,
      $global:MoreUpdates=0,
      $global:MaxCycles=5,
      $MaxUpdatesPerCycle=500)

# Windows Update API Result codes
$global:OperationResultCodes=@{
    0 = 'Not Started'
    1 = 'In Progress'
    2 = 'Succeeded'
    3 = 'Succeeded With Errors'
    4 = 'Failed'
    5 = 'Aborted'
}

$Logfile = 'C:\Users\vagrant\Documents\PackerWindowsUpdates.log'

function ExitAndRunNextBuildScript {
    Write-Host "Windows Update process complete. Running next Packer build script`n"
    # Allow time to view output before window is closed
    Start-Sleep -Seconds 2
    $NextScript = 'A:\SetupWinRM.ps1'
    Invoke-Expression -Command "$NextScript -AutoStart"
}

function LogWrite {
   param ([string]$Logstring)
   $Now = Get-Date -Format s
   Add-Content $Logfile -value "$Now $Logstring"
   Write-Host $Logstring
}

function Check-ContinueRestartOrEnd() {
    $RegistryKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
    $RegistryEntry = 'InstallWindowsUpdates'
    switch ($global:RestartRequired) {
        0 {
            $prop = (Get-ItemProperty $RegistryKey).$RegistryEntry
            if ($prop) {
                LogWrite 'Restart Registry Entry Exists - Removing It'
                Remove-ItemProperty -Path $RegistryKey -Name $RegistryEntry -ErrorAction SilentlyContinue
            }

            LogWrite 'No Restart Required'
            Check-WindowsUpdates

            if (($global:MoreUpdates -eq 1) -and ($Cycles -le $global:MaxCycles)) {
                Install-WindowsUpdates
            } elseif ($Cycles -gt $global:MaxCycles) {
                LogWrite 'Exceeded Cycle Count - Stopping'
                ExitAndRunNextBuildScript
            } else {
                LogWrite 'Done Installing Windows Updates'
                ExitAndRunNextBuildScript
            }
        }
        1 {
            $prop = (Get-ItemProperty $RegistryKey).$RegistryEntry
            if (-not $prop) {
                LogWrite 'Restart Registry Entry Does Not Exist - Creating It'
                # Create the registry entry value
                $PSexe = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
                $Value = $Value = "$($PSexe) -File $($ScriptPath) -MaxUpdatesPerCycle $($MaxUpdatesPerCycle)"
                # Create the registry entry that will run the updates script post reboot
                Set-ItemProperty -Path $RegistryKey -Name $RegistryEntry -Value $Value
            } else {
                LogWrite 'Restart Registry Entry Exists Already'
            }

            LogWrite 'Restart Required - Restarting...'
            # Allow time to view output before window is closed
            Start-Sleep -Seconds 5
            Restart-Computer
        }
        default {
            LogWrite 'Unsure If A Restart Is Required'
            break
        }
    }
}

function Install-WindowsUpdates() {
    $Cycles++
    LogWrite "Evaluating Available Updates with limit of $($MaxUpdatesPerCycle):"
    $UpdatesToDownload = New-Object -ComObject 'Microsoft.Update.UpdateColl'
    $i = 0
    $CurrentUpdates = $script:SearchResult.Updates
    while($i -lt $CurrentUpdates.Count -and $CycleUpdateCount -lt $MaxUpdatesPerCycle) {
        $Update = $CurrentUpdates.Item($i)
        if ( ($Update -ne $null) -and (-not $Update.IsDownloaded) ) {
            [bool]$addThisUpdate = $false
            if ($Update.InstallationBehavior.CanRequestUserInput) {
                LogWrite "  Skipping: $($Update.Title) because it requires user input"
            } else {
                if ( -not ($Update.EulaAccepted)) {
                    LogWrite "  Note: $($Update.Title) has a license agreement that must be accepted. Accepting the license."
                    $Update.AcceptEula()
                    [bool]$addThisUpdate = $true
                    $CycleUpdateCount++
                } else {
                    [bool]$addThisUpdate = $true
                    $CycleUpdateCount++
                }
            }

            if ([bool]$addThisUpdate) {
                LogWrite "  Adding $($Update.Title) to download list"
                $UpdatesToDownload.Add($Update) |Out-Null
            }
        }
        $i++
    }

    if ($UpdatesToDownload.Count -eq 0) {
        LogWrite ''
        LogWrite 'No Updates To Download...'
    } else {
        LogWrite ''
        LogWrite "Now entering download phase..."
        # Create the interface we can use to download updates
        $Downloader = $script:UpdateSession.CreateUpdateDownloader()

        # Loop over all the updates we need and download
        $MaxAttempts = 3 # Max number of attempts we will make to download each update
        $ConsecFailures = 0 # Counter for updates that have failed to download
        $MaxConsecFailures = 3 # Max consecutive downloads allowed to fail before failing the overall task
        $TaskNumber = 0 # Overall progress counter
        $TasksTotal = $UpdatesToDownload.Count # Total downloads required
        $DownloadedUpdates = 0 # Successfully downloaded update counter

        $UpdatesToDownload | % {
            $TaskNumber += 1
            LogWrite "* Download [$TaskNumber of $TasksTotal] Attempting to download $($_.Title)"
            [bool]$Downloaded = $false
            $Attempts = 0
            do {
                # Create the required 'collection' object for the individual update
                $IndividualUpdate = New-Object -ComObject 'Microsoft.Update.UpdateColl'
                # Add this update to the collection
                $IndividualUpdate.Add($_) | Out-Null
                # Add the individual update to the download interface
                $Downloader.Updates = $IndividualUpdate
                # Finally download
                $Result = $Downloader.Download()
                LogWrite "  Download result: $($OperationResultCodes[$Result.ResultCode])"
                if ($Result.HResult -eq 0) {
                    [bool]$Downloaded = $true
                    $DownloadedUpdates += 1
                    $ConsecFailures = 0
                } else {
                    $Attempts += 1
                    if ($Attempts -lt $MaxAttempts) {
                        LogWrite "  Download attempt [$Attempts of $MaxAttempts] failed. Retrying in 10 seconds"
                        Start-Sleep -Seconds 10
                    } else {
                        LogWrite "  Download attempt [$Attempts of $MaxAttempts] failed. Skipping update"
                        $ConsecFailures += 1
                        LogWrite "  Consecutive failures: [$ConsecFailures] Max consecutive failures: [$MaxConsecFailures]"
                    }
                }
            } while ( (-not $Downloaded) -and ($Attempts -lt $MaxAttempts) )
            if ( $ConsecFailures -eq $MaxConsecFailures ) {
                LogWrite 'ERROR: Max consecutive download failure limit reached.'
                LogWrite 'ERROR: Failed to download updates. Exiting'
                exit # Exiting here means the Packer build will stop
            }
        }
        LogWrite ''
        LogWrite "Downloaded [$DownloadedUpdates of $TasksTotal] updates"
    }

    # Download summary
    if ($DownloadedUpdates -gt 0) {
        LogWrite 'Download Summary:'
        LogWrite 'The following updates are downloaded and ready to be installed:'
        [bool]$RebootMayBeRequired = $false
        # Log and check if the update will required a reboot
        foreach ($Update in $script:SearchResult.Updates) {
            if ($Update.IsDownloaded) {
                LogWrite "* $($Update.Title)"
                if ($Update.InstallationBehavior.RebootBehavior -gt 0) {
                    [bool]$RebootMayBeRequired = $true
                }
            }
        }
        if ($RebootMayBeRequired) {
            # The reboot requirement is only definitively known once the install result is returned
            LogWrite 'These updates may require a reboot'
        }
    } else {
        LogWrite 'No updates available to install'
        $global:MoreUpdates = 0
        $global:RestartRequired = 0
        ExitAndRunNextBuildScript
        break
    }

    # Installation phase
    LogWrite ''
    LogWrite "Proceeding to Installation phase"
    # Create the interface used to install updates
    $Installer = $script:UpdateSession.CreateUpdateInstaller()

    # Loop over required updates and install those that have been downloaded
    # Create a 'collection' object to store details of updates whose install fail
    $UpdatesFailedInstall = New-Object -ComObject 'Microsoft.Update.UpdateColl'
    $TasksTotal = $DownloadedUpdates # Install tasks will be equal to the number of updates downloaded
    $TaskNumber = 0 # Progress Counter
    $InstalledUpdates = 0 # Counter for number of successfully installed updates
    $global:RestartRequired=0
    foreach ($Update in $script:SearchResult.Updates) {
        if ($Update.IsDownloaded) {
            $TaskNumber += 1
            LogWrite "* Install [$TaskNumber of $TasksTotal] Attempting to install $($Update.Title)"
            # Create the required 'collection' object for the individual update
            $UpdateToInstall = New-Object -ComObject 'Microsoft.Update.UpdateColl'
            # Add this update to the collection
            $UpdateToInstall.Add($Update) | Out-Null
            # Add the individual update to the install interface
            $Installer.Updates = $UpdateToInstall
            # Finally install
            $Result = $Installer.Install()
            LogWrite "  Installation Result: $($OperationResultCodes[$Result.ResultCode])"
            if ($Result.ResultCode -eq 2) { # A result code of 2 indicates the installation succeeded
                $InstalledUpdates += 1
                # Now the update has been installed we can definitively determine if a restart will be required
                if ($Result.RebootRequired) {
                    LogWrite '  This update requires a reboot to complete'
                    $global:RestartRequired=1
                }
            } else {
                # Store the details of the update that failed to install
                $UpdatesFailedInstall.add($Update) | Out-Null
            }
        }
    }

    LogWrite "[$InstalledUpdates of $DownloadedUpdates] updates were installed successfully"
    if ($UpdatesFailedInstall.Count -gt 0) {
        LogWrite ''
        LogWrite "WARNING: The following updates failed to install properly:"
        foreach ($Update in $UpdatesFailedInstall) {
            LogWrite "* Install failed: $($Update.Title)"
        }
        LogWrite "Continuing as it is possible the updates will install correctly on the next pass"
    }

    LogWrite ''
    LogWrite "Completed installation of updates"
    if ($global:RestartRequired) {
        LogWrite 'A restart is now required'
    } else {
        LogWrite 'No restart is required'
    }

    Check-ContinueRestartOrEnd
}

function Check-WindowsUpdates() {
    LogWrite 'Checking For Windows Updates'
    $Username = $env:USERDOMAIN + '\' + $env:USERNAME

    New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue
    $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID '104' -EntryType 'Information' -Message $Message

    LogWrite "Script: $ScriptPath"
    LogWrite "Script User: $Username"
    LogWrite "Started: $((Get-Date).toString())"

    LogWrite ''
    LogWrite 'Searching for applicable updates. This may take some time to complete...'
    LogWrite 'There will be no output while the search is undertaken'

    # Create the interface we can use to search for updates
    $script:UpdateSearcher = $script:UpdateSession.CreateUpdateSearcher()

    # Start a synchronous search for updates
    [bool]$Successful = $false
    $Attempts = 0
    $MaxAttempts = 12
    while(-not $Successful -and $Attempts -lt $MaxAttempts) {
        try {
            # Don't return updates that are already installed or hidden. Limit search to software (exclude drivers).
            $script:SearchResult = $script:UpdateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
            [bool]$Successful = $true
        } catch {
            LogWrite 'WARNING: Search call to UpdateSearcher was unsuccessful. Retrying in 10s'
            $Attempts = $Attempts + 1
            Start-Sleep -Seconds 10
        }
    }
    LogWrite ''
    LogWrite "Search complete"

    if ($script:SearchResult.Updates.Count -ne 0) {
        LogWrite "Number of applicable updates: $($script:SearchResult.Updates.Count)"
        LogWrite ''
        foreach ($Update in $script:SearchResult.Updates) {
            LogWrite "Title: $($Update.Title)"
            LogWrite "Description: $($Update.Description)"
            LogWrite "Reboot required: $($Update.RebootRequired)"
            LogWrite "EULA Accepted:   $($Update.EulaAccepted)"
            LogWrite ''
        }
        $global:MoreUpdates=1
    } else {
        LogWrite 'There are no applicable updates'
        $global:RestartRequired=0
        $global:MoreUpdates=0
    }
}

$ScriptName = $MyInvocation.MyCommand.ToString()
$ScriptPath = $MyInvocation.MyCommand.Path
$script:UpdateSession = New-Object -ComObject 'Microsoft.Update.Session'
$script:UpdateSession.ClientApplicationID = 'Packer Windows Update Installer'
$script:UpdateSearcher = $script:UpdateSession.CreateUpdateSearcher()
$script:SearchResult = New-Object -ComObject 'Microsoft.Update.UpdateColl'
$Cycles = 0
$CycleUpdateCount = 0

Check-WindowsUpdates
if ($global:MoreUpdates -eq 1) {
    Install-WindowsUpdates
} else {
    Check-ContinueRestartOrEnd
}
