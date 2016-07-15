#!/usr/bin/env bash
#
# Install the open-vm-tools package for better management and interaction
# with VMware based guest VM's
#
# Debian based systems no longer need to install the tools bundled with
# Workstation or Fusion to enable support for shared folders. This used to
# be necessary due to a bug in the packaging of open-vm-tools. A fix is
# now in place and is available from the backports repository.
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


# Path to the APT sources file
APT_SOURCE="/etc/apt/sources.list"

# Create a list of all configured repositories
REPO_LIST=$(apt-cache policy | grep http: | cut -d' ' -f4 | \
            cut -d'\' -f1 | sort -u | tr '\n' ' ')


# Enable the backports repository if required
if [ "x$(echo ${REPO_LIST} | grep jessie-backports)" = "x" ]
then
    echo "Adding backports repository to APT sources..." > $REDIRECT
    printf "%s" "\

        # Enable the backports repository
        deb http://httpredir.debian.org/debian jessie-backports main
    " | sed 's/^ *//g' >> ${APT_SOURCE}
fi

# Ensure debconf does not ask any questions
export DEBIAN_FRONTEND="noninteractive"

# Make APT aware of the new packages available from the backports repo
apt-get update > ${REDIRECT}

# Install the fuse package and then open-vm-tools from the backports repo
apt-get -y install fuse > ${REDIRECT}
apt-get -y -t jessie-backports install open-vm-tools > ${REDIRECT}


exit 0
