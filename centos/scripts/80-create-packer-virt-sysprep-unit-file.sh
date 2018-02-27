#!/usr/bin/env bash
#
# Dynamically create the packer-virt-sysprep systemd unit file using
# settings in the packer configuration template

# Packer logging
echo "Creating packer-virt-sysprep systemd unit file..."

# Unit file
UNIT_FILE_LOCATION="/etc/systemd/system/packer-virt-sysprep.service"
UNIT="${UNIT_FILE_LOCATION##*/}"

# The directory that is to be used to hold all packer-virt-sysprep files
# and operations scripts is specified in the Packer configuration template
# and exported as an environment variable
PREFIX="${PACKER_VIRT_SYSPREP_DIR}"

# Write the unit file
printf "%s" "\
[Unit]
Description=Virt-sysprep style operations for Packer builds
Before=shutdown.target reboot.target halt.target
Requires=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/true
# Run all required packer-virt-sysprep operations
ExecStop=${PREFIX}/packer-virt-sysprep-run-ops.sh
# Remove all packer-virt-sysprep scripts; Disable and remove associated
# systemd services upon first use
ExecStop=/usr/bin/rm -rf ${PACKER_VIRT_SYSPREP_DIR}
# Use find/rm to disable and remove the unit file as systemd seems to run
# into problems when systemctl commands are used within a unit file
ExecStop=/usr/bin/find /etc/systemd/system/ -name ${UNIT} \
    -exec /usr/bin/rm -f '{}' \;

[Install]
WantedBy=multi-user.target
" >${UNIT_FILE_LOCATION}

exit 0
