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
ExecStop=/bin/rm -rf ${PACKER_VIRT_SYSPREP_DIR}
# Use find/rm to disable and remove the unit file as systemd seems to run
# into problems when systemctl commands are used within a unit file
ExecStop=/usr/bin/find /etc/systemd/system/ -name ${UNIT} \
    -exec /bin/rm -f '{}' \;

[Install]
WantedBy=multi-user.target
" >${UNIT_FILE_LOCATION}

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

echo "Setting up the packer-virt-sysprep service with systemd..."

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
