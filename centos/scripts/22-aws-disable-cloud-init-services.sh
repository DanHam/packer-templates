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
# This script disables the cloud-init services

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Disabling cloud-init to avoid first run during AWS image import..."

CLOUD_INIT_SVCS=(
  cloud-config.service
  cloud-final.service
  cloud-init-local.service
  cloud-init.service
)

for CLOUD_INIT_SVC in ${CLOUD_INIT_SVCS[@]}
do
    echo "Stopping and disabling ${CLOUD_INIT_SVC}..." > ${REDIRECT}
    systemctl stop ${CLOUD_INIT_SVC} >/dev/null 2>&1
    systemctl disable ${CLOUD_INIT_SVC} >/dev/null 2>&1
done

exit 0
