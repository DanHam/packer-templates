#!/usr/bin/env bash
#
# Creates a systemd unit to clean up artifacts left over from the Amazon
# Import Image process. Additionally repair some issues caused by bugs in
# Amazons import scripts. Execution of the unit is deferred until the
# boot initiated by the Amazon import process. The unit will remove itself
# with a clean up script run upon ExecStop.
#
# This script dynamically creates the unit file using environment
# variables set in the Packer configuration template and exported by
# Packer.

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Creating systemd unit to rm import artifacts + fix import issues..."

# Set up from variables exported from Packer configuration template
UNIT="${AWS_IMPORT_FIX_UNIT}"
UNIT_FILE="/etc/systemd/system/${UNIT}"
UNIT_SCRIPTSD="${AWS_IMPORT_FIX_DIR}"
FIXES_SCRIPT="${UNIT_SCRIPTSD}/${AWS_IMPORT_FIX_FIXES_SCRIPT}"
CLEAN_SCRIPT="${UNIT_SCRIPTSD}/${AWS_IMPORT_FIX_CLEAN_SCRIPT}"


# Create a directory to hold the units scripts
echo "Creating dir to hold units scripts: ${UNIT_SCRIPTSD}" >${REDIRECT}
mkdir ${UNIT_SCRIPTSD}


# Write the unit file
echo "Creating unit file for ${UNIT}..." > ${REDIRECT}
echo "Unit file location: ${UNIT_FILE}" > ${REDIRECT}
echo "AWS import clean up and fixes script: ${FIXES_SCRIPT}" > ${REDIRECT}
echo "Unit disable and clean up script: ${CLEAN_SCRIPT}" > ${REDIRECT}

printf "%s" "\
[Unit]
Description=Remove Amazon AMI import artifacts and fix import issues
After=basic.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=${FIXES_SCRIPT}
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
