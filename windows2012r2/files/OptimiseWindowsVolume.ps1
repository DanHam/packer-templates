# Defragment and optimise the Windows volume

# The option of whether or not to optimise the Windows volume is
# configured from within the Packer template and exported as an
# environment variable
If ( $env:OPTIMISE_WIN_VOLUME -ne $true ) {
    Write-Host 'Skipping optimisation of the Windows volume as requested'
    Write-Host 'Exiting'
    exit
}

Write-Host 'Performing optimisations on the Windows volume as requested'
Write-Host 'This may take some time to complete...'
Optimize-Volume -DriveLetter C -Defrag | Out-Null

Write-Host 'Complete'
