#!/usr/bin/env bash
#
# Install the Virtualbox Guest Additions. Compilition of the additions
# requires the following packages be installed:
#
#   * gcc
#   * make
#   * linux-headers-$(uname -r)
#   * bzip2
#
# We won't need to compile the Guest Additions again as we would rebuild
# the image should a kernel update be required. As such, we can remove the
# packages once the Guest Additions have been built.
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "${DEBUG:-false}" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Ensure debconf does not ask any questions
export DEBIAN_FRONTEND="noninteractive"

# Set up list of packages required to build the Guest Additions
build_deps=(
    gcc
    make
    linux-headers-"$(uname -r)"
    bzip2
)
# Initialise the array used to store the list of packages needed just for
# the build of the Guest Additions
build_pkgs=()

# Check through the list of required packages adding any that are not
# installed to the list. These packages will be removed once complete
for pkg in "${build_deps[@]}"
do
    if ! dpkg -s "${pkg}" &>/dev/null; then
        build_pkgs+=("${pkg}")
    fi
done

# Install required packages for build
if [ ${#build_pkgs[@]} -gt 0 ]; then
    echo "Ensuring packages required to build Guest Additions are installed..."
    apt-get -y install "${build_pkgs[@]}" > ${redirect}
fi

# Set the path to the Virtualbox tools iso using the environment variable
# defined in the Packer template and created on this system by Packer
guest_additions_iso="${GUEST_ADDITIONS_PATH}"
# Exit if the environment variable is not set/empty
if [ -z "${guest_additions_iso}" ]; then
    echo "ERROR: Failed to set path to Virtualbox Additions ISO. Exiting"
    exit 1
fi
# Exit if the iso has not been uploaded
if [ ! -e "${guest_additions_iso}" ]; then
    echo "ERROR: Could not find ISO at ${guest_additions_iso}. Exiting"
    exit 1
fi

# Create a mount point for the Guest Additions ISO avoiding any possible
# name conflicts under /tmp through use of mktemp
guest_additions_mnt="$(mktemp -t -d --tmpdir=/tmp vbox-mnt-XXXXXX)"
# Set the full path to the Guest Additions Installation script
guest_additions_installer="${guest_additions_mnt}/VBoxLinuxAdditions.run"

# Mount the ISO
mount -o loop "${guest_additions_iso}" "${guest_additions_mnt}" -o ro

# Run the Virtualbox installer
#
# The Virtualbox installer returns:
#
# * 0 if the kernel modules were properly created and loaded
# * 1 if the modules could not be build or loaded (except due to already
#     running older modules)
# * 2 if running modules probably prevented the new ones from loading
#
# An exit code of 2 is fine as the new modules will be used after the
# system is restarted. As such we need to temporarily disable the option to
# exit on error
echo "Installing Virtualbox Guest Additions..."
set +o errexit
sh "${guest_additions_installer}" > ${redirect}
# Only an exit code of 1 should be considered an error
if [ $? -eq 1 ]; then
    echo 'An error occurred installing the Virtualbox Guest additions'
    echo 'The installer returned an exit code of 1'
    exit 1
fi
set -o errexit

# Clean up
# Unmount the Guest Additions ISO
umount "${guest_additions_mnt}"
# Remove the temp directories and uploaded ISO
rm -rf "${guest_additions_mnt}" "${guest_additions_iso}"

# Remove packages (and any deps) required for compiling the Guest Additions
if [ ${#build_pkgs[@]} -gt 0 ]; then
    echo "Removing packages installed only to build the Guest Additions..."
    apt-get -y autoremove "${build_pkgs[@]}" > ${redirect}
fi

exit 0
