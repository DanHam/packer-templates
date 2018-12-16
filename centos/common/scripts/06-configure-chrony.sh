#!/usr/bin/env bash
#
# Configure time synchronisation with chrony

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Exit if chrony is not installed
CHRONY="$(rpm -qa | grep chrony)"
if [ "x${CHRONY}" = "x" ]; then
    echo "Skipping configuration of chrony as it is not installed..."
    exit 0
fi

# Packer logging
echo "Configuring chrony..."

# Location of chrony configuration file
CHRONY_CONF="/etc/chrony.conf"
# Chrony Daemon
CHRONYD="chronyd.service"


# Stop the Chrony Daemon if it is running
if [ "$(systemctl is-active ${CHRONYD})" = "active" ]; then
    systemctl stop ${CHRONYD} > ${REDIRECT}
fi

# Configure
#
# With virtual or cloud based instances interaction with a RTC is not
# desirable and can cause issues
#
# Disable automatic synchronisation of the system and RTC with the
# rtcautotrim directive
sed -i "s/^\(rtcautotrim\)/#\1/" ${CHRONY_CONF}
# Since we don't want to interact with the RTC we can comment out the name
# of the device file used to access it
sed -i "s/^\(rtcdevice\)/#\1/" ${CHRONY_CONF}
# Since we don't want to interact with the RTC we don't need to track its
# accuracy in a file
sed -i "s/^\(rtcfile\)/#\1/" ${CHRONY_CONF}
# Do not assume that the RTC is on UTC
sed -i "s/^\(rtconutc\)/#\1/" ${CHRONY_CONF}
# Disable copying of system time to the RTC
sed -i "s/^\(rtcsync\)/#\1/" ${CHRONY_CONF}

# Disable logging of measurements, statistics, tracking etc
sed -i "s/^\(log \)/#\1/" ${CHRONY_CONF}

# Virtual or cloud based instances should never be used as a time source
sed -i "s/^\(allow\)/#\1/" ${CHRONY_CONF}
if [ "x$(cat ${CHRONY_CONF} | grep 'deny all')" = "x" ]; then
    printf "%s" "\

    # Disable use of this machine as a time server
    deny all
    " | sed "s/^    //g" >>${CHRONY_CONF}
fi


# Ensure Chrony is set to start on boot
systemctl enable ${CHRONYD} > ${REDIRECT}

exit 0
