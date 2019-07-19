#!/usr/bin/env bash
#
# Zero out free space in filesystems in preparation for disk defrag and
# shrink utilties provided by some virtualisation plaforms.
# These utilities are automatically called by Packer as appropriate
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
#
# Note: When used on a partition the dd commands below will always returns
# an error when there is no more space left in the filesystem. As such, we
# need to explicitly return true to avoid inadvertantly triggering the
# 'errexit' option
set -o errexit

# Set verbose/quiet output and configure redirection appropriately
debug=false
[[ "${debug}" = true ]] && redirect="/zero-fs.log" || redirect="/dev/null"

echo "Running script to zero out free space in filesystems..." >> ${redirect}

# Get the mount point of all block based file system partitions
fsblk_mntpoint="$(lsblk --list --output MOUNTPOINT,TYPE,FSTYPE | \
                  grep part | \
                  grep -v swap | \
                  cut -d' ' -f1)"

# Loop over each partition or exit if we failed to find any
if [ "x${fsblk_mntpoint}" != "x" ]; then
    for i in ${fsblk_mntpoint}
    do
        echo "Performing actions on ${i} to maximise efficiency of" \
             "compacting" >> ${redirect}
        dd if=/dev/zero of=${i}/ZERO bs=1M 2>/dev/null || true &>> ${redirect}
        zero_file_size="$(du -sh ${i}/ZERO)"
        rm -f ${i}/ZERO
        echo "The zero file size was ${zero_file_size}" >> ${redirect}
        # Ensure file system buffers are flushed before continuing
        sync
    done
else
    echo "ERROR: Could not find any block based FS partitions." \
         "Exiting" >> ${redirect}
    exit 1
fi


# Perform actions on swap space to maximise efficiency of compacting
if swapon --summary | grep partition &>/dev/null; then
    echo "Swap partition found" >> ${redirect}
    # Use the lsblk utility to enumerate required information about the
    # configured swap partition
    swap_info="$(lsblk --list --paths --output FSTYPE,NAME,UUID,LABEL | \
                 grep ^swap | \
                 tr -s '[:space:]' ' ')"
    swap_device="$(echo "${swap_info}" | cut -d' ' -f2)"
    swap_uuid="$(echo "${swap_info}" | cut -d' ' -f3)"
    swap_label="$(echo "${swap_info}" | cut -d' ' -f4)"

    echo "Swap device: ${swap_device}" >> ${redirect}
    echo "Swap UUID: ${swap_uuid}" >> ${redirect}
    if [ "x${swap_label}" = "x" ]; then
        echo "The label for the swap partition was not set" >> ${redirect}
        echo "Setting swap partition label to 'SWAP'" >> ${redirect}
        swap_label="SWAP"
    else
        echo "Swap Label: ${swap_label}" >> ${redirect}
    fi
    echo "Zeroing out swap partition to maximise efficiency of" \
         "compacting" >> ${redirect}

    # Deactivate the swap
    swapoff UUID=${swap_uuid}
    # Zero out the partition
    dd if=/dev/zero of=${swap_device} bs=1M 2>/dev/null || true &>> ${redirect}
    # Set up the linux swap area on the partition reusing the existing UUID
    # and label as required
    mkswap --uuid ${swap_uuid} --label "${swap_label}" ${swap_device} >> \
        ${redirect}
    # Ensure file system buffers are flushed before continuing
    sync
    # Make the OS aware of the changes to the partition table
    partprobe
else
    echo "No active swap partition found" >> ${redirect}
fi

if swapon --summary | grep file &>/dev/null; then
    echo "Swap file found" >> ${redirect}
    # Use the swapon command to enumerate required information about the
    # configured swap file
    swap_info="$(swapon --summary | grep file | tr -s '[:space:]' ' ')"
    swap_file="$(echo "${swap_info}" | cut -d' ' -f1)"
    swap_blocks="$(echo "${swap_info}" | cut -d' ' -f3)"
    swap_label="$(swaplabel ${swap_file} | \
                  sed -n '/^LABEL:/ s/^LABEL: \(.*\)/\1/g p')"

    echo "Swap file: ${swap_file}" >> ${redirect}
    echo "Swap size in blocks: ${swap_blocks}" >> ${redirect}
    if [ "x${swap_label}" = "x" ]; then
        echo "The label for the swap file was not set" >> ${redirect}
        echo "Setting swap file label to 'SWAP'" >> ${redirect}
        swap_label="SWAP"
    else
        echo "Swap Label: ${swap_label}" >> ${redirect}
    fi
    echo "Zeroing out swap file to maximise efficiency of" \
         "compacting" >> ${redirect}

    # Deactivate the swap
    swapoff ${swap_file}
    # Delete the swap file
    rm -f ${swap_file}
    # Recreate and zero out the swap file with the space required
    dd if=/dev/zero of=${swap_file} bs=1024 count=${swap_blocks} &>> \
        ${redirect}
    # Set permissions to secure the swap file for RW by root only
    chmod 600 ${swap_file}
    # Set up the linux swap file
    mkswap ${swap_file} --label "${swap_label}" >> ${redirect}
    # Ensure file system buffers are flushed before continuing
    sync
else
    echo "No active swap file found" >> ${redirect}
fi

echo "Complete" >> ${redirect}

# Ensure logging output is written to disk as the next steps in the
# shutdown process unmount the filesystems
sync

exit 0
