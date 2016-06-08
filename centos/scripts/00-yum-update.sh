#!/usr/bin/env bash
#
# Update installed packages and initiate system restart as required

# Path to CentOS 7 RPM GPG signing key
RPM_GPG_KEY="/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7"
# CentOS 7 Official Signing Key ID
RPM_GPG_KEY_ID="f4a80eb5"
# CentOS 7 Official Signing Key Fingerprint
RPM_GPG_KEY_FINGER="6341 AB27 53D7 8A78 A7C2  7BB1 24C6 A8A7 F4A8 0EB5"
# Set the location for storing the list of updates from yum check-update
UPDATE_FILE="/tmp/updates.txt"
# Create a grep friendly list of packages that require a system reboot
# after being updated on RHEL/CentOS 7
# https://access.redhat.com/solutions/27943
REBOOT_LIST="-e ^kernel -e ^glibc -e ^linux-firmware -e ^systemd -e ^udev"
# Initialise Reboot flag
REBOOT=0


# Ensure the CentOS RPM GPG key has been imported
if [ "x$(rpm -qa gpg-pubkey* | grep $RPM_GPG_KEY_ID)" = "x" ]; then
    # Check the finger print of the key matches the known value
    FINGER="$(gpg -q --with-fingerprint $RPM_GPG_KEY |\
              grep fingerprint | \
              sed -n -e 's/^.*= //p')"
    if [ "$FINGER" == "$RPM_GPG_KEY_FINGER" ]; then
        rpm --import $RPM_GPG_KEY &> /dev/null
    else
        echo "ERROR: CentOS RPM GPG key does not match known fingerprint"
        exit -1
    fi
fi


# Check if updates are required and store the list of update packages
yum check-update > $UPDATE_FILE
# yum check-update provides the following exit codes:
#     100 => updates are available
#     1   => an error occurred
#     0   => no updates
EXIT_CODE=$?

if [ $EXIT_CODE == 100 ]; then
    echo "Package updates required. Updating..."
    yum -y update > /dev/null
    # Check the list of updates output by yum check-updates against the
    # list of packages that require a system restart post update
    while read LINE
    do
        # ...and set to reboot if we have a matching package
        [[ "x$(echo $LINE | grep $REBOOT_LIST)" != "x" ]] && REBOOT=1
    done <$UPDATE_FILE
elif [ $EXIT_CODE == 1 ]; then
    echo "An error occurred checking if there are updates for this system"
    exit -1
else
    echo "No packages on the system require updating."
fi


# Remove cached packages and metadata from the yum repository
yum clean all > /dev/null
# Remove temp files
[[ -e $UPDATE_FILE ]] && rm -f $UPDATE_FILE


# Reboot if required
if [ $REBOOT == 1 ]; then
    echo "System restart required post install of updates. Rebooting..."
    sleep 5
    reboot
    # Sleep to ensure Packer doesn't start executing the next script before
    # the ssh connection is killed by the reboot
    sleep 60
fi

exit 0
