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
# This script dynamically creates the script used to clean up and remove all
# unit files, scripts and directories used to defer cloud-init services once
# the unit has run. This is referenced in the associated unit file in the
# ExecStop field.
# The script is created using variables set in the Packer configuration
# template. These are exported by Packer as environment variables.

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Creating systemd unit script that will clean up/remove this unit..."


# Set up from variables exported from Packer configuration template
UNIT="${DEFER_CLOUD_INIT_SVC_UNIT}"
UNIT_FILE="/etc/systemd/system/${UNIT}"
UNIT_SCRIPTSD="${DEFER_CLOUD_INIT_SVC_DIR}"
ENABLE_SCRIPT="$UNIT_SCRIPTSD/${DEFER_CLOUD_INIT_SVC_ENABLE}"
CLEAN_SCRIPT="$UNIT_SCRIPTSD/${DEFER_CLOUD_INIT_SVC_CLEAN}"


# Write out the scripts to clean up the cloud-init-defer service
echo "Clean cloud-init defer unit script: ${CLEAN_SCRIPT}" > ${REDIRECT}
printf "%s" "\
#!/usr/bin/env bash
#
# Remove all defer-cloud-init service scripts and unit files

# Remove the scripts directory
rm -rf ${UNIT_SCRIPTSD}

# Disable and then remove the defer-cloud-init service
systemctl disable ${UNIT} >/dev/null 2>&1
rm -f ${UNIT_FILE}
# Reload to reflect changes
systemctl daemon-reload

exit 0
" >${CLEAN_SCRIPT}

# Script must be executable
chmod u+x ${CLEAN_SCRIPT}

exit 0
