#!/usr/bin/env bash
#
# Configure system time and date settings
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Packer logging
echo "Configuring system time and date settings..."

# Service Daemons
chronyd="chronyd.service"
ntpd="ntpd.service"

# Configure system date time to be set from Network time source when
# the chronyd or ntpd service is enabled
if [[ "$(systemctl is-enabled ${chronyd} 2>/dev/null)" == "enabled" || \
      "$(systemctl is-enabled ${ntpd} 2>/dev/null)" == "enabled" ]]; then
    echo "System time configured to use NTP based source" > ${redirect}
    timedatectl set-ntp true
else
    echo "System time will not use an NTP based source" > ${redirect}
    timedatectl set-ntp false
fi

# Disable unsupported reading of time from the RTC in the local time zone
echo "Disabling system setting of the RTC" > ${redirect}
timedatectl set-local-rtc false

exit 0
