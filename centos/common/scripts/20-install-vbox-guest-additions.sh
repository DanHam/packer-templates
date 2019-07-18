#!/usr/bin/env bash
#
# Install the Virtualbox Guest Additions. Compilition of the additions
# requires the following packages be present on the system:
#
#   * gcc
#   * make
#   * kernel-devel
#   * bzip2
#
# We won't need to compile the Guest Additions again as we would rebuild
# the image should a kernel update be required. As such, we can remove the
# packages once the Guest Additions have been built.
# Note that make is installed as part of the base installation and so is
# not explicitly included in the package list below
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Install required package
packages="gcc kernel-devel bzip2"
echo "Installing packages required to compile Virtualbox Additions..."
yum -y install ${packages} > ${redirect}

# Set the path to the Virtualbox tools iso using the environment variable
# defined in the Packer template and created on this system by Packer
guest_additions_iso="${GUEST_ADDITIONS_PATH}"
# Exit if the environment variable is not set
if [ "x${guest_additions_iso}" == "x" ]; then
    echo "ERROR: Failed to set path to Virtualbox Additions ISO. Exiting"
    exit 1
fi
# Exit if the iso has not been uploaded
if [ ! -e ${guest_additions_iso} ]; then
    echo "ERROR: Could not find ISO at ${guest_additions_iso}. Exiting"
    exit 1
fi

# Create a mount point for the Guest Additions ISO avoiding any possible
# name conflicts under /tmp through use of mktemp
guest_additions_mnt="$(mktemp -t -d --tmpdir=/tmp vbox-mnt-XXXXXX)"
# Set the full path to the Guest Additions Installation script
guest_additions_installer="${guest_additions_mnt}/VBoxLinuxAdditions.run"

# Mount the ISO
mount -o loop ${guest_additions_iso} ${guest_additions_mnt} -o ro

# Run the Virtualbox installer
echo "Installing Virtualbox Guest Additions..."
sh ${guest_additions_installer} > ${redirect}

# Clean up
# Unmount the Guest Additions ISO
umount ${guest_additions_mnt}
# Remove the temp directories and uploaded ISO
rm -rf ${guest_additions_mnt} ${guest_additions_iso}

# Remove the packages and any dependancies required for compiling
echo "Removing packages required to compile Virtualbox Additions..."
yum remove -y --setopt="clean_requirements_on_remove=1" ${packages} > \
    ${redirect}

exit 0
