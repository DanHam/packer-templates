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
# This script dynamically creates the script to enable cloud-init services.
# This is referenced in the associated unit file in the ExecStart field.
# The script is created using variables set in the Packer configuration
# template. These are exported by Packer as environment variables.

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Creating systemd unit script that will enable cloud-init services..."

# Set up from variables exported from Packer configuration template
UNIT_SCRIPTSD="${DEFER_CLOUD_INIT_SVC_DIR}"
ENABLE_SCRIPT="$UNIT_SCRIPTSD/${DEFER_CLOUD_INIT_SVC_ENABLE}"


# Write out the script that will enable cloud-init services
# Note: use of single quotes prevents expansion of vars in script
echo "Enable cloud-init services script: ${ENABLE_SCRIPT}" > ${REDIRECT}
printf "%s" \
'#!/usr/bin/env bash
#
# Enable cloud-init services so first run occurs when any instance created
# from the imported AMI is first booted

CLOUD_INIT_SVCS=(
  cloud-config.service
  cloud-final.service
  cloud-init-local.service
  cloud-init.service
)

# Enable all cloud-init services
for CLOUD_INIT_SVC in ${CLOUD_INIT_SVCS[@]}
do
    systemctl enable ${CLOUD_INIT_SVC} >/dev/null 2>&1
done

exit 0
' >${ENABLE_SCRIPT}

# Script must be executable
chmod u+x ${ENABLE_SCRIPT}

exit 0
