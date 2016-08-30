#!/usr/bin/env bash
#
# Install the Virtualbox Guest Additions. Compilition of the additions
# requires the following packages be installed:
#
#   * gcc
#   * make
#   * linux-headers-$(uname -r)
#   * bzip2

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Ensure debconf does not ask any questions
export DEBIAN_FRONTEND="noninteractive"

# Configure list of packages that need to be installed
PACKAGES=" gcc make linux-headers-$(uname -r) bzip2"
# Install required package
echo "Installing packages required to compile Virtualbox Additions..."
apt-get -y install ${PACKAGES} > ${REDIRECT}

# Set the path to the Virtualbox tools iso using the environment variable
# defined in the Packer template and created on this system by Packer
GUEST_ADDITIONS_ISO="${GUEST_ADDITIONS_PATH}"
# Exit if the environment variable is not set
if [ "x${GUEST_ADDITIONS_ISO}" == "x" ]; then
    echo "ERROR: Failed to set path to Virtualbox Additions ISO. Exiting"
    exit -1
fi
# Exit if the iso has not been uploaded
if [ ! -e ${GUEST_ADDITIONS_ISO} ]; then
    echo "ERROR: Could not find ISO at ${GUEST_ADDITIONS_ISO}. Exiting"
    exit -1
fi

# Create a mount point for the Guest Additions ISO avoiding any possible
# name conflicts under /tmp through use of mktemp
GUEST_ADDITIONS_MNT="$(mktemp -t -d --tmpdir=/tmp vbox-mnt-XXXXXX)"
# Set the full path to the Guest Additions Installation script
GUEST_ADDITIONS_INSTALLER="${GUEST_ADDITIONS_MNT}/VBoxLinuxAdditions.run"

# Mount the ISO
mount -o loop ${GUEST_ADDITIONS_ISO} ${GUEST_ADDITIONS_MNT} -o ro

# Run the VMware Installer Perl script with required options
echo "Installing Virtualbox Guest Additions..."
sh ${GUEST_ADDITIONS_INSTALLER} > ${REDIRECT}

# Clean up
# Unmount the Guest Additions ISO
umount ${GUEST_ADDITIONS_MNT}
# Remove the temp directories and uploaded ISO
rm -rf ${GUEST_ADDITIONS_MNT} ${GUEST_ADDITIONS_ISO}

exit 0
