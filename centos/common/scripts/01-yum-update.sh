#!/usr/bin/env bash
#
# Update installed packages and initiate system restart as required
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Path to CentOS 7 RPM GPG signing key
rpm_gpg_key="/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7"
# CentOS 7 Official Signing Key ID
rpm_gpg_key_id="f4a80eb5"
# CentOS 7 Official Signing Key Fingerprint
rpm_gpg_key_finger="6341 AB27 53D7 8A78 A7C2  7BB1 24C6 A8A7 F4A8 0EB5"

# Ensure the CentOS RPM GPG key has been imported
if ! rpm -qa | grep gpg-pubkey | grep ${rpm_gpg_key_id} &>/dev/null; then
    # Check the finger print of the key matches the known value
    finger="$(gpg -q --with-fingerprint ${rpm_gpg_key} 2>${redirect} |\
              grep fingerprint | \
              sed -n -e 's/^.*= //p')"
    if [ "${finger}" == "${rpm_gpg_key_finger}" ]; then
        rpm --import ${rpm_gpg_key}
    else
        echo "ERROR: CentOS RPM GPG key does not match known fingerprint"
        exit 1
    fi
fi

# Check if updates are required
yum check-update > ${redirect}
# yum check-update provides the following exit codes:
#     100 => updates are available
#     1   => an error occurred
#     0   => no updates
exit_code=$?

if [ ${exit_code} == 100 ]; then
    echo "Package updates required. Updating..."
    yum -y update > ${redirect}
    # If the kernel was updated then the linux-firmware package may have
    # been installed as a dependancy. We don't need this so remove
    if rpm -q linux-firmware &>/dev/null; then
        echo "Removing linux-firmware package installed with updates"
        yum -C -y remove linux-firmware > ${redirect}
    fi
elif [ ${exit_code} == 1 ]; then
    echo "An error occurred checking if there are updates for this system"
    exit 1
else
    echo "No packages on the system require updating."
fi

# Remove cached packages and metadata from the yum repository
yum clean all > ${redirect}

# Reboot if required. The needs-restarting command returns 1 if a restart
# is required or 0 otherwise
# The 'needs-restarting' command is provided by the yum-utils package
if ! rpm -q yum-utils &>/dev/null; then
    echo "Installing yum-utils to provide the 'needs-restarting' command"
    yum -C -y install yum-utils > ${redirect}
fi

if ! needs-restarting --reboothint &>/dev/null; then
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
    nohup shutdown --reboot now </dev/null &>/dev/null &
fi

exit 0
