#!/usr/bin/env bash
#
# Create a user for Vagrant and configure. Required values are set in the
# packer configuration file and injected into the build environment as
# environment variables. Note that we do not set a password and as such
# password based authentication is disabled. Additionally note ssh has
# been configured to only allow authentication via ssh keys.

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Creating user for Vagrant and setting up required options..."

echo "User:      ${VAGRANT_USER}"               > ${REDIRECT}
echo "Group:     ${VAGRANT_GROUP}"              > ${REDIRECT}
echo "UID:       ${VAGRANT_UID}"                > ${REDIRECT}
echo "GID:       ${VAGRANT_GID}"                > ${REDIRECT}
echo "Groups:    ${VAGRANT_GROUPS}"             > ${REDIRECT}
echo "Shell:     ${VAGRANT_SHELL}"              > ${REDIRECT}
echo "GECOS:     ${VAGRANT_GECOS}"              > ${REDIRECT}
echo "SSH key:   ${VAGRANT_SSH_AUTHORISED_KEY}" > ${REDIRECT}

# Create the required group
groupadd --gid ${VAGRANT_GID} ${VAGRANT_GROUP}

# Create the user
useradd --create-home --uid ${VAGRANT_UID} --gid ${VAGRANT_GID} \
        --groups ${VAGRANT_GROUPS} --shell ${VAGRANT_SHELL} \
        --comment "${VAGRANT_GECOS}" ${VAGRANT_USER}

# Configure authorised ssh keys for Vagrant
SSH_DIR="/home/${VAGRANT_USER}/.ssh"
[[ -d ${SSH_DIR} ]] || mkdir ${SSH_DIR}
chmod 700 ${SSH_DIR}
echo ${VAGRANT_SSH_AUTHORISED_KEY} > ${SSH_DIR}/authorized_keys
chmod 600 ${SSH_DIR}/authorized_keys
chown -R ${VAGRANT_USER}:${VAGRANT_GROUP} ${SSH_DIR}

# If set disable the requirement for a TTY with sudo see:
# https://bugzilla.redhat.com/show_bug.cgi?id=1020147
sed -i '/^Defaults .*requiretty/ s/^/# /g' /etc/sudoers

# Configure password-less sudo for Vagrant user
SUDOERS_USER="/etc/sudoers.d/admin-user"
cat <<EOF > ${SUDOERS_USER}
# Allow admin user to run commands as root without providing a password
${VAGRANT_USER}  ALL=(ALL)  NOPASSWD: ALL
# Disable the requirement for a TTY with sudo see:
# https://bugzilla.redhat.com/show_bug.cgi?id=1020147
Defaults:${VAGRANT_USER} !requiretty
EOF
chmod 0440 ${SUDOERS_USER}

exit 0
