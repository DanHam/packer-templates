#!/usr/bin/env bash
#
# Enable apt sources for Ansible. Note that the apt repo is the same as
# that used for Ubuntu
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Configuring Apt sources to obtain the latest Ansible release..."

aptfile="/etc/apt/sources.list.d/ansible-ppa.list"
cat << EOF > ${aptfile}
# Debian utilises the same apt repository as Ubuntu
deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main
EOF

# Prepare for and then install Ubuntu's package signing key
export DEBIAN_FRONTEND="noninteractive"
# The dirmngr package is needed by apt-key and GPG to process the signing key
apt-get install -y dirmngr > ${redirect}
apt-key adv --keyserver keyserver.ubuntu.com \
            --recv-keys 93C4A3FD7BB9C367 > ${redirect}

# Update the apt-cache
apt-get update > ${redirect}

exit 0
