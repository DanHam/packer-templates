#!/usr/bin/env bash
#
# Configure packages beneficial when running as a cloud instance

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Cloud tools configuration..."
echo "This script does nothing yet"

exit 0
