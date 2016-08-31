#!/usr/bin/env bash
#
# Install packages of benefit when running as a cloud instance
#
# The current version of cloud-init available from the default package
# repositories is rather old and has some fairly serious bugs/issues.
# In contrast the version available from backports is much more up to date
# and incorporates many fixes and improvements.

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Installing packages beneficial when running as a cloud instance..."


# Path to the APT sources file
APT_SOURCE="/etc/apt/sources.list"


# Create a list of all configured repositories
REPO_LIST=$(apt-cache policy | grep http: | cut -d' ' -f4 | \
            cut -d'\' -f1 | sort -u | tr '\n' ' ')

# Enable the backports repository if required
if [ "x$(echo ${REPO_LIST} | grep jessie-backports)" = "x" ]
then
    echo "Adding backports repository to APT sources..." > ${REDIRECT}
    printf "%s" "\

        # Enable the backports repository
        deb http://httpredir.debian.org/debian jessie-backports main
    " | sed 's/^ *//g' >> ${APT_SOURCE}
fi


# Ensure debconf does not ask any questions
export DEBIAN_FRONTEND="noninteractive"

# Make APT aware of the new packages available from the backports repo
apt-get update > ${REDIRECT}

# Install cloud-init and cloud-guest-utils (for growpart and ec2metadata
# scripts)
echo "Installing cloud-init from backports..." > ${REDIRECT}
apt-get -y -t jessie-backports install cloud-init > ${REDIRECT}
echo "Installing cloud-guest-utils..." > ${REDIRECT}
apt-get -y install cloud-guest-utils > ${REDIRECT}


exit 0
