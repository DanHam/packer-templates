#!/usr/bin/env bash
#
# The AWS Image Import service boots the imported VM as part of the import
# process. This means that first time the cloud-init modules run is during
# the import process. Clearly this is not what was intended.
# To avoid this we need to defer the start up of the cloud init services
# so the first run of cloud-init occurs when the instance created from the
# AMI is first booted.
# This is implemented through a systemd service that runs at next boot
# when the VM is booted as part of the import process. The service enables
# the cloud-init services so that their first run is the boot after next
# e.g. when any instance created from the imported AMI is first run as
# intended.
#
# This script dynamically creates the unit file and associated directory
# used to hold scripts using variables set in the Packer configuration
# template. These are exported by Packer as environment variables.
# Once created the unit is enabled and set to run at next boot

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Creating systemd unit to set up deferred running of cloud-init..."

# Set up from variables exported from Packer configuration template
UNIT="${DEFER_CLOUD_INIT_SVC_UNIT}"
UNIT_FILE="/etc/systemd/system/${UNIT}"
UNIT_SCRIPTSD="${DEFER_CLOUD_INIT_SVC_DIR}"
ENABLE_SCRIPT="$UNIT_SCRIPTSD/${DEFER_CLOUD_INIT_SVC_ENABLE}"
CLEAN_SCRIPT="$UNIT_SCRIPTSD/${DEFER_CLOUD_INIT_SVC_CLEAN}"


# Create a directory to hold the service scripts
echo "Creating dir to hold units scripts: ${UNIT_SCRIPTSD}" >${REDIRECT}
mkdir ${UNIT_SCRIPTSD}


# Write the unit file
echo "Creating unit file for ${UNIT}..." > ${REDIRECT}
echo "Unit file location: ${UNIT_FILE}" > ${REDIRECT}
echo "Enable cloud-init script: ${ENABLE_SCRIPT}" > ${REDIRECT}
echo "Clean up script: ${CLEAN_SCRIPT}" > ${REDIRECT}

printf "%s" "\
[Unit]
Description=Defer initial run of cloud-init for AWS AMI imports
After=basic.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=${ENABLE_SCRIPT}
ExecStop=${CLEAN_SCRIPT}

[Install]
WantedBy=multi-user.target
" >${UNIT_FILE}

# Unit files should have the following permissions
chmod 0664 ${UNIT_FILE}


# Reload systemd to pick up the newly created unit
systemctl daemon-reload
# Enable the unit used to defer cloud-init. The unit will run during the
# AWS image import process
systemctl enable ${UNIT} >/dev/null 2>&1


exit 0
