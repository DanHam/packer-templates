#!/usr/bin/env bash
#
# Install the open-vm-tools package for better management and interaction
# with VMware based guest VM's
#
# Debian based systems no longer need to install the tools bundled with
# Workstation or Fusion to enable support for shared folders. This used to
# be necessary due to a bug in the packaging of open-vm-tools. A fix is
# now in place and is available from the backports repository.
# Unfortunately there is still a bug in the backports package - the fuse
# package is now a dependancy of open-vm-tools (fuse is required to use
# shared folders/hgfs) but this dependancy is missing from the package
# configuration. As such, at present the fuse package must be manually
# installed.
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
