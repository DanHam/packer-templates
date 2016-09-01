#!/usr/bin/env bash
#
# Dynamically create the packer-virt-sysprep systemd unit file using
# settings in the packer configuration template

# Packer logging
echo "Creating packer-virt-sysprep systemd unit file..."

# Unit file
UNIT_FILE_LOCATION="/etc/systemd/system/packer-virt-sysprep.service"

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
ExecStop=${PREFIX}/packer-virt-sysprep-run-ops.sh
ExecStop=${PREFIX}/packer-virt-sysprep-cleanup.sh

[Install]
WantedBy=multi-user.target
" >${UNIT_FILE_LOCATION}

exit 0
