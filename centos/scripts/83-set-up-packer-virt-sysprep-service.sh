#!/usr/bin/env bash
#
# Set up the packer-virt-sysprep service
#
# In systemd terms:
# * If the unit is STARTED it will run whatever virt-sysprep style
#   operations have been requested when the next shutdown occurs.
# * If the unit is ENABLED the execution of whatever virt-sysprep style
#   operations have been requested will be deferred until the shutdown
#   sequence after next.
#
# The requirement or need to defer running of the sysprep operations is due
# to the way the amazon import service works. In brief, the import service
# actually boots the imported machine in order to prepare it for running on
# AWS. It is only after this step that the image is imported as an AMI. As
# such any previous attempts to prepare the image with virt-sysprep style
# operations will be undone by this preparatory boot-prepare-shutdown
# sequence. Deferring the running of the packer-virt-sysprep service
# means that the requested operations will be run when the machine is
# shutdown at the end of the amazon import process. As a consequence the
# resulting AMI will be created and prepared with the requested
# virt-sysprep style operations.
#
# The choice of whether to run or defer running of the packer-virt-sysprep
# operations is set in the Packer configuration template and exported as an
# environment variable

# Packer logging
echo "Setting up the packer-virt-sysprep service with systemd..."

# Unit name
UNIT="packer-virt-sysprep.service"

# First make systemd aware of the newly created packer-virt-sysprep unit
systemctl daemon-reload

# Set to run or defer the running of the packer-virt-sysprep operations
# based on the setting in the Packer configuration template
if [ "${PACKER_VIRT_SYSPREP_DEFER_RUN}" = true ]; then
    echo "Packer-virt-sysprep ops deferred until shutdown after next"
    SYSTEMCTL_COMMAND="enable"
else
    echo "Packer-virt-sysprep ops will be run at next shutdown"
    SYSTEMCTL_COMMAND="start"
fi

# Enable or start the service
systemctl ${SYSTEMCTL_COMMAND} ${UNIT} >/dev/null 2>&1

exit 0
