#!/usr/bin/env bash
#
# Create a user and configure. Required values are set in the packer
# configuration file and injected into the build environment as
# environment variables. Note that we do not set a password and as such
# password based authentication is disabled. Additionally note ssh has
# been configured to only allow authentication via ssh keys.
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "${DEBUG:-false}" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Exit unless user creation was requested in the packer template
if [ "${ADMIN_CREATE}" = true ]; then
    echo "Creating an admin user and setting up required options..."
else
    echo "Skipping creation of an admin user as requested..."
    exit 0
fi

echo "User:      ${ADMIN_USER}"               > ${redirect}
echo "Group:     ${ADMIN_GROUP}"              > ${redirect}
echo "UID:       ${ADMIN_UID}"                > ${redirect}
echo "GID:       ${ADMIN_GID}"                > ${redirect}
echo "Groups:    ${ADMIN_GROUPS}"             > ${redirect}
echo "Shell:     ${ADMIN_SHELL}"              > ${redirect}
echo "GECOS:     ${ADMIN_GECOS}"              > ${redirect}
echo "SSH key:   ${ADMIN_SSH_AUTHORISED_KEY}" > ${redirect}

# Create the required group
groupadd --gid ${ADMIN_GID} ${ADMIN_GROUP}

# Create the user
useradd --create-home --uid ${ADMIN_UID} --gid ${ADMIN_GID} \
        --groups ${ADMIN_GROUPS} --shell ${ADMIN_SHELL} \
        --comment "${ADMIN_GECOS}" ${ADMIN_USER}

# Configure authorised ssh keys
ssh_dir="/home/${ADMIN_USER}/.ssh"
[[ -d ${ssh_dir} ]] || mkdir ${ssh_dir}
chmod 700 ${ssh_dir}
echo ${ADMIN_SSH_AUTHORISED_KEY} > ${ssh_dir}/authorized_keys
chmod 600 ${ssh_dir}/authorized_keys
chown -R ${ADMIN_USER}:${ADMIN_GROUP} ${ssh_dir}

# Configure password-less sudo for the admin user
sudoers_user="/etc/sudoers.d/admin-user"
cat <<EOF > ${sudoers_user}
# Allow admin user to run commands as root without providing a password
${ADMIN_USER}  ALL=(ALL)  NOPASSWD: ALL
EOF
chmod 0440 ${sudoers_user}

exit 0
