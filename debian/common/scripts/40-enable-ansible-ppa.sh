#!/usr/bin/env bash
#
# Enable apt sources for Ansible. Note that the apt repo is the same as
# that used for Ubuntu

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Logging for packer
echo "Configuring Apt sources to obtain the latest Ansible release..."

APTFILE="/etc/apt/sources.list.d/ansible-ppa.list"
cat << EOF > ${APTFILE}
# Debian utilises the same apt repository as Ubuntu
deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main
EOF

# Prepare for and then install Ubuntu's package signing key
export DEBIAN_FRONTEND="noninteractive"
# The dirmngr package is needed by apt-key and GPG to process the signing key
apt-get install -y dirmngr > ${REDIRECT}
apt-key adv --keyserver keyserver.ubuntu.com \
            --recv-keys 93C4A3FD7BB9C367 > ${REDIRECT}

# Update the apt-cache
apt-get update > ${REDIRECT}

exit 0
