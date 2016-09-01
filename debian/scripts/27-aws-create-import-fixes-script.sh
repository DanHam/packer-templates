#!/usr/bin/env bash
#
# Creates a systemd unit to clean up artifacts left over from the Amazon
# Import Image process. Additionally repair some issues caused by bugs in
# Amazons import scripts. Execution of the unit is deferred until the
# boot initiated by the Amazon import process. The unit will remove itself
# with a clean up script run upon ExecStop.
#
# This script dynamically creates the script run by the units ExecStart
# stanza to remove the import artifacts and implement required fixes. It
# uses environment variables set in the Packer configuration template and
# subsequently exported by Packer.

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Creating unit script to remove/fix AWS import artifacts & issues..."

# Set up from variables exported from Packer configuration template
UNIT_SCRIPTSD="${AWS_IMPORT_FIX_DIR}"
FIXES_SCRIPT="${UNIT_SCRIPTSD}/${AWS_IMPORT_FIX_FIXES_SCRIPT}"


# Write the script to implement the fixes and removal of import artifacts
echo "Writing out script: ${FIXES_SCRIPT}" > ${REDIRECT}
printf "%s" \
'#!/usr/bin/env bash
#
# AWS Import service artifact removal and fixes

# First remove all import artifacts - Amazon re-names scripts using
# vmimport as a prefix or suffix
find / -type f -iname "*vmimport*" | xargs -I FILE rm -f FILE

exit 0
' > ${FIXES_SCRIPT}

# Script must be executable
chmod u+x ${FIXES_SCRIPT}

exit 0
