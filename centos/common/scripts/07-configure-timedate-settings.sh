#!/usr/bin/env bash
#
# Configure system time and date settings

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Configuring system time and date settings..."

# Service Daemons
CHRONYD="chronyd.service"
NTPD="ntpd.service"

# Configure system date time to be set from Network time source when
# the chronyd or ntpd service is enabled
if [[ "$(systemctl is-enabled ${CHRONYD} 2>/dev/null)" == "enabled" || \
      "$(systemctl is-enabled ${NTPD} 2>/dev/null)" == "enabled" ]]; then
    echo "System time configured to use NTP based source" > ${REDIRECT}
    timedatectl set-ntp true
else
    echo "System time will not use an NTP based source" > ${REDIRECT}
    timedatectl set-ntp false
fi

# Disable unsupported reading of time from the RTC in the local time zone
echo "Disabling system setting of the RTC" > ${REDIRECT}
timedatectl set-local-rtc false

exit 0
