#!/usr/bin/env bash
#
# Disable unsupported reading of time from the RTC in the local time zone

# Packer logging
echo "Disabling reading of time from RTC in local time zone..."

timedatectl set-local-rtc 0

exit 0
