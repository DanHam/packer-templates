#!/usr/bin/env bash
#
# Install the open-vm-tools package for better management and interaction
# with VMware based guest VM's

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"


# Configure shared folder support if requested in the packer template
if [ "${VMTOOLS_SHARED_FOLDERS}" = true ]
then
    echo "Configuring system to allow use of shared host/guest folders..."
else
    exit 0
fi


# Ensure the open-vm-tools package is installed
if [ "x$(dpkg -l | grep open-vm-tools)" = "x" ]
then
    echo "ERROR: Open VM tools installation not found. Exiting"
    exit 1
fi


# Create the required mountpoint
[[ ! -d /mnt/hgfs ]] && mkdir /mnt/hgfs


# Add the required incantation to /etc/fstab if requested in the packer
# configuration file. Note that this is not required for Vagrant but only
# for convenience with user configured shares.
# Configured shares will be available to under /mnt/hgfs/<share name> and
# will be have rw permissions for all users
if [ "${VMTOOLS_SHARED_FOLDERS_FSTAB}" = true ]
then
    if [ "x$(cat /etc/fstab | grep vmhgfs-fuse)" = "x" ]
    then
        echo "Adding required line to /etc/fstab..." > ${REDIRECT}
        printf "%s" "\
            # Enable use of shared folders for VMware Workstation and Fusion
            .host:/ /mnt/hgfs fuse.vmhgfs-fuse rw,nosuid,nodev,uid=0,gid=0,allow_other,users,defaults 0 0
        " | sed 's/^ *//g' >> /etc/fstab
    fi
fi


exit 0
