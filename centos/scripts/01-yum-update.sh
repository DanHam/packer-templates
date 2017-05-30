#!/usr/bin/env bash
#
# Update installed packages and initiate system restart as required

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Path to CentOS 7 RPM GPG signing key
RPM_GPG_KEY="/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7"
# CentOS 7 Official Signing Key ID
RPM_GPG_KEY_ID="f4a80eb5"
# CentOS 7 Official Signing Key Fingerprint
RPM_GPG_KEY_FINGER="6341 AB27 53D7 8A78 A7C2  7BB1 24C6 A8A7 F4A8 0EB5"
# Set the location for storing the list of updates from yum check-update
# using mktemp to avoid potential name conflicts under /tmp
UPDATE_FILE="$(mktemp -t -q --tmpdir=/tmp updates-XXXXXX.txt)"
# Create a grep friendly list of packages that require a system reboot
# after being updated on RHEL/CentOS 7
# https://access.redhat.com/solutions/27943
REBOOT_LIST="-e ^kernel -e ^glibc -e ^linux-firmware -e ^systemd -e ^udev"
# Initialise Reboot flag
REBOOT=0


# Ensure the CentOS RPM GPG key has been imported
if [ "x$(rpm -qa gpg-pubkey* | grep $RPM_GPG_KEY_ID)" = "x" ]; then
    # Check the finger print of the key matches the known value
    FINGER="$(gpg -q --with-fingerprint $RPM_GPG_KEY 2>$REDIRECT |\
              grep fingerprint | \
              sed -n -e 's/^.*= //p')"
    if [ "$FINGER" == "$RPM_GPG_KEY_FINGER" ]; then
        rpm --import $RPM_GPG_KEY
    else
        echo "ERROR: CentOS RPM GPG key does not match known fingerprint"
        exit -1
    fi
fi


# Check if updates are required and store the list of update packages
yum check-update > $UPDATE_FILE
#: yum check-update provides the following exit codes:
#     100 => updates are available
#     1   => an error occurred
#     0   => no updates
EXIT_CODE=$?

if [ $EXIT_CODE == 100 ]; then
    echo "Package updates required. Updating..."
    yum -y update > $REDIRECT
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
yum clean all > $REDIRECT
# Remove temp files
[[ -e $UPDATE_FILE ]] && rm -f $UPDATE_FILE


# Reboot if required
if [ $REBOOT == 1 ]; then
    echo "System restart required post install of updates."
    echo "Stopping the ssh server and then rebooting..."
    # Give time for the output to be logged/sent back to Packer
    sleep 1 # ... ok, so it's pretty quick!
    # Regardless of what we try and do with shutdown commands there still
    # seem to be certain situations under which Packer will freeze due to
    # a reboot interupting a ssh session. Currently, this behaviour occurs
    # when, having completed execution of this script, Packer will
    # establish a new ssh session to clean up and remove this script.
    # The connection is successfully established while the machine is
    # shutting down. Packer then doesn't seem to pick up that the
    # connection has dissapeared and sits there doing nothing! This only
    # occurs with the Virtualbox builder, and then only if headless is set
    # to true, and all that has only occurred after the change to CentOS
    # 7.3...
    # Although rather ugly, for the time being it seems it's safer to
    # deliberately kill the ssh session so that Packer detects the
    # disconnect and then cannot reconnect until the reboot is complete
    systemctl stop sshd.service
    # Reboot
    nohup shutdown --reboot now </dev/null >/dev/null 2>&1 &
fi

exit 0
