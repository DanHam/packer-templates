#!/usr/bin/env bash
#
# Dynamically create the packer-virt-sysprep cleanup script using
# settings in the packer configuration template
#
# The clean up script is executed by the packer-virt-sysprep.service unit
# file and is responsible for disabling the packer-virt-sysprep.service and
# then removing all associated files, scripts and unit files. In effect
# this script should make it appear as though the packer-virt-sysprep
# service, operation scripts and files never existed.

# Packer logging
echo "Creating packer-virt-sysprep clean up script..."

# Unit file and Unit
UNIT_FILE_LOCATION="/etc/systemd/system/packer-virt-sysprep.service"
UNIT="${UNIT_FILE_LOCATION##*/}"

# The directory that is to be used to hold all packer-virt-sysprep files
# and operations scripts is specified in the Packer configuration template
# and exported as an environment variable
PREFIX="${PACKER_VIRT_SYSPREP_DIR}"

# Clean up script location. This is referenced and run by the unit file.
CLEAN_SCRIPT="${PREFIX}/packer-virt-sysprep-cleanup.sh"

# Write the clean up script
printf "%s" "\
#!/usr/bin/env bash
#
# Remove all packer scripts and systemd services

# Remove the packer scripts directory
rm -rf ${PACKER_VIRT_SYSPREP_DIR}

# Disable and then remove the packer systemd service
systemctl disable ${UNIT}
rm -f ${UNIT_FILE_LOCATION}
# Reload to reflect changes
systemctl daemon-reload

exit 0
" >${CLEAN_SCRIPT}

# Scripts to be run by systemd unit files must have the executable bit set
chmod u+x ${CLEAN_SCRIPT}


exit 0
