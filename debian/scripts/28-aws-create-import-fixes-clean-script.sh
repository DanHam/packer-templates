#!/usr/bin/env bash
#
# Creates a systemd unit to clean up artifacts left over from the Amazon
# Import Image process. Additionally repair some issues caused by bugs in
# Amazons import scripts. Execution of the unit is deferred until the
# boot initiated by the Amazon import process. The unit will remove itself
# with a clean up script run upon ExecStop.
#
# This script dynamically creates the script run by the units ExecStop
# stanza to disable and remove this unit and associated files. It uses
# environment variables set in the Packer configuration template and
# subsequently exported by Packer.

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Creating unit script to disable and remove this unit and files..."

# Set up from variables exported from Packer configuration template
UNIT="${AWS_IMPORT_FIX_UNIT}"
UNIT_FILE="/etc/systemd/system/${UNIT}"
UNIT_SCRIPTSD="${AWS_IMPORT_FIX_DIR}"
FIXES_SCRIPT="${UNIT_SCRIPTSD}/${AWS_IMPORT_FIX_FIXES_SCRIPT}"
CLEAN_SCRIPT="${UNIT_SCRIPTSD}/${AWS_IMPORT_FIX_CLEAN_SCRIPT}"

# Write the script to implement the fixes and removal of import artifacts
echo "Writing out script: ${CLEAN_SCRIPT}" > ${REDIRECT}
printf "%s" "\
#!/usr/bin/env bash
#
# Disable AWS import fixes unit and remove all associated files

# Remove the scripts directory
rm -rf ${UNIT_SCRIPTSD}

# Disable and then remove the defer-cloud-init service
systemctl disable ${UNIT} >/dev/null 2>&1
rm -f ${UNIT_FILE}
# Reload to reflect changes
systemctl daemon-reload

exit 0
" > ${CLEAN_SCRIPT}

# Script must be executable
chmod u+x ${CLEAN_SCRIPT}

exit 0
