#!/usr/bin/env bash
#
# Zero out free space in filesystems in preparation for disk defrag and
# shrink with vmware-vdiskmanager. vmware-vdiskmanager is called by Packer
# in the final stages of the build.
#
# Special treatment is needed if the VM has swap configured:
#
# For a swap partition the basic process is:
# - Deactivate the swap partition
# - Fill the partition will zeros
# - Recreate the swap area effectively creating a pristine swap partition
#
# For a swap file the basic process is:
# - Deactivate the swap file
# - Delete the existing swap file
# - Zero out a file with the space required for recreating the swap file
# - Recreate the swap area effectively creating a pristine swap file
#
# Blanking out or deleting and recreating the swap in this way ensures the
# vmdk file is reduced to its minimum possible size when compacted with
# vmware-vdiskmanager

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

echo "Running script to zero out free disk space... does nothing yet!"


exit 0
