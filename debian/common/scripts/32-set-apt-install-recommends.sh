#!/usr/bin/env bash
#
# Restore the default Debian behaviour of installing 'recommended'
# packages as if they were dependencies
set -o errexit

# Restore the default behaviour if requested in the packer template
if [ "${APT_INSTALL_RECOMMENDS}" = true ]; then
    echo "Restoring default APT behaviour of installing 'Recommends'..."
else
    exit 0
fi

# Path to relevant APT configuration file
apt_recommends="/etc/apt/apt.conf.d/00InstallRecommends"

if [ -e ${apt_recommends} ]; then
    # Although simply deleting the file would restore the default
    # behaviour it's convenient to have it left in place in case the
    # user wants to revert change this setting in the future
    sed -i '/^APT::Install-Recommends/ s/false/true/' ${apt_recommends}
fi

exit 0
