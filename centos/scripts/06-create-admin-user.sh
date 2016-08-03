#!/usr/bin/env bash
#
# Create a user and configure. Required values are set in the packer
# configuration file and injected into the build environment as
# environment variables. Note that we do not set a password and as such
# password based authentication is disabled. Additionally note ssh has
# been configured to only allow authentication via ssh keys.

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Creating an admin user and setting up required options..."

echo "User:      ${ADMIN_USER}"               > ${REDIRECT}
echo "Group:     ${ADMIN_GROUP}"              > ${REDIRECT}
echo "UID:       ${ADMIN_UID}"                > ${REDIRECT}
echo "GID:       ${ADMIN_GID}"                > ${REDIRECT}
echo "Groups:    ${ADMIN_GROUPS}"             > ${REDIRECT}
echo "Shell:     ${ADMIN_SHELL}"              > ${REDIRECT}
echo "GECOS:     ${ADMIN_GECOS}"              > ${REDIRECT}
echo "SSH key:   ${ADMIN_SSH_AUTHORISED_KEY}" > ${REDIRECT}

# Create the required group
groupadd --gid ${ADMIN_GID} ${ADMIN_GROUP}

# Create the user
useradd --create-home --uid ${ADMIN_UID} --gid ${ADMIN_GID} \
        --groups ${ADMIN_GROUPS} --shell ${ADMIN_SHELL} \
        --comment "${ADMIN_GECOS}" ${ADMIN_USER}

# Configure authorised ssh keys
SSH_DIR="/home/${ADMIN_USER}/.ssh"
[[ -d ${SSH_DIR} ]] || mkdir ${SSH_DIR}
chmod 700 ${SSH_DIR}
echo ${ADMIN_SSH_AUTHORISED_KEY} > ${SSH_DIR}/authorized_keys
chmod 600 ${SSH_DIR}/authorized_keys
chown -R ${ADMIN_USER}:${ADMIN_GROUP} ${SSH_DIR}

# If set disable the requirement for a TTY with sudo see:
# https://bugzilla.redhat.com/show_bug.cgi?id=1020147
# This is a requirement when configuring for use with Vagrant
sed -i '/^Defaults .*requiretty/ s/^/# /g' /etc/sudoers

# Configure password-less sudo for the admin user
SUDOERS_USER="/etc/sudoers.d/admin-user"
cat <<EOF > ${SUDOERS_USER}
# Allow admin user to run commands as root without providing a password
${ADMIN_USER}  ALL=(ALL)  NOPASSWD: ALL
# Disable the requirement for a TTY with sudo see:
# https://bugzilla.redhat.com/show_bug.cgi?id=1020147
Defaults:${ADMIN_USER} !requiretty
EOF
chmod 0440 ${SUDOERS_USER}

exit 0
