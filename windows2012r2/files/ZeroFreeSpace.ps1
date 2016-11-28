# Zero-out free space in the Windows Volume
#
# Zeroing out free space can help to optimise post image compaction steps

# The option of whether or not to zero-out free space is configured
# from within the Packer template and exported as an environment variable
If ( $env:ZERO_FREE_SPACE -ne $true ) {
    Write-Host 'Skipping zero of free space on Windows volume as requested'
    Write-Host 'Exiting'
    exit
}

Write-Host 'Zeroing out remaining space on the Windows volume'
Write-Host 'Depending on drive size/performance this may take some time'

# Script Settings
$FilePath = 'c:\zero.tmp'
$ArraySize = 64kb

# Get required volume information
Write-Host '* Calculating size for zero file'
$Volume = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
# Calculate size of zero file to create leaving 5% of overall disk space
$Reserved = [math]::truncate( $Volume.Size * 0.05 ) # Ensure Int result
$FileSize = $Volume.FreeSpace - $Reserved

# Write out the file
Write-Host '* Writing out zero file'
$ZeroArray = new-object byte[]($ArraySize)
$Stream = [io.File]::OpenWrite($FilePath)
try {
   $CurFileSize = 0
    while($CurFileSize -lt $FileSize) {
        $Stream.Write($ZeroArray, 0, $ZeroArray.Length)
        $CurFileSize += $ZeroArray.Length
    }
}
finally {
    if($Stream) {
        $Stream.Close()
    }
}

# Delete the Zero file once complete
Remove-Item -Path $FilePath -Force

Write-Host 'Complete'
