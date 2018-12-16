#!/usr/bin/env bash
#
# Install the open-vm-tools package for better management and interaction
# with VMware based guest VM's
#
# Debian based systems no longer need to install the tools bundled with
# Workstation or Fusion to enable support for shared folders.
#
# The fuse package is required for shared folder support. However, fuse
# is only listed as a 'recommended' package in the open-vm-tools package.
# By default APT is configured to install recommended packages as if they
# are actual dependencies. Unfortunately, this results in a large number
# of unnecessary packages being installed and much larger machine images.
# For a minimal install of Debian this equates to 60+ packages and an
# image size of +250MB.
# As such, the APT option to 'install recommended packages as if they are
# dependencies' is often set to false by many system builders.
# Long and short, if this is the case then the fuse package needs to be
# installed manually. If this is not the case, the inclusion of a command
# to install fuse will not hurt anything.
#
# Note that additional steps are required to enable access to shared
# folders within the guest

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Installing open-vm-tools..."

# Ensure debconf does not ask any questions
export DEBIAN_FRONTEND="noninteractive"

# Install the fuse package and then open-vm-tools from the backports repo
apt-get -y install fuse > ${REDIRECT}
apt-get -y install open-vm-tools > ${REDIRECT}

exit 0
