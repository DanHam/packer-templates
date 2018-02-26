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

# Set verbose/quiet output and configure redirection appropriately
DEBUG=false
[[ "${DEBUG}" = true ]] && REDIRECT="/zero-fs.log" || REDIRECT="/dev/null"

echo "Running script to zero out free space in filesystems..." >> ${REDIRECT}

# Get the mount point of all block based file system partitions
FSBLK_MNTPOINT="$(lsblk --list --output MOUNTPOINT,TYPE,FSTYPE | \
                  grep part | \
                  grep -v swap | \
                  cut -d' ' -f1)"

# Loop over each partition or exit if we failed to find any
if [ "x${FSBLK_MNTPOINT}" != "x" ]; then
    for i in ${FSBLK_MNTPOINT}
    do
        echo "Performing actions on ${i} to maximise efficiency of" \
             "compacting" >> ${REDIRECT}
        dd if=/dev/zero of=${i}/ZERO bs=1M &>> ${REDIRECT}
        ZERO_FILE_SIZE="$(du -sh ${i}/ZERO)"
        rm -f ${i}/ZERO
        echo "The zero file size was ${ZERO_FILE_SIZE}" >> ${REDIRECT}
        # Ensure file system buffers are flushed before continuing
        sync
    done
else
    echo "ERROR: Could not find any block based FS partitions. " \
         "Exiting" >> ${REDIRECT}
    exit -1
fi


# Perform actions on swap space to maximise efficiency of compacting
if [ "x$(swapon -s | grep partition)" != "x" ]; then
    echo "Swap partition found" >> ${REDIRECT}
    # Use the lsblk utility to enumerate required information about the
    # configured swap partition
    SWAP_INFO="$(lsblk --list --paths --output NAME,UUID,FSTYPE | \
                 grep swap | \
                 tr -s '[:space:]' ' ')"
    SWAP_DEVICE="$(echo "${SWAP_INFO}" | cut -d' ' -f1)"
    SWAP_UUID="$(echo "${SWAP_INFO}" | cut -d' ' -f2)"

    echo "Swap device: ${SWAP_DEVICE}" >> ${REDIRECT}
    echo "Swap UUID: ${SWAP_UUID}" >> ${REDIRECT}
    echo "Zeroing out swap partition to maximise efficiency of " \
         "compacting" >> ${REDIRECT}

    # Deactivate the swap
    swapoff -U ${SWAP_UUID}
    # Zero out the partition
    dd if=/dev/zero of=${SWAP_DEVICE} bs=1M &>> ${REDIRECT}
    # Set up the linux swap area on the partition specifying a label to
    # allow swapon by label if required
    mkswap -U ${SWAP_UUID} -L 'SWAP' ${SWAP_DEVICE} >> ${REDIRECT}
    # Ensure file system buffers are flushed before continuing
    sync
elif [ "x$(swapon -s | grep file)" != "x" ]; then
    echo "Swap file found" >> ${REDIRECT}
    # Use the swapon command to enumerate required information about the
    # configured swap file
    SWAP_INFO="$(swapon -s | grep file | tr -s '[:space:]' ' ')"
    SWAP_FILE="$(echo "${SWAP_INFO}" | cut -d' ' -f1)"
    SWAP_BLOCKS="$(echo "${SWAP_INFO}" | cut -d' ' -f3)"

    echo "Swap file: ${SWAP_FILE}" >> ${REDIRECT}
    echo "Swap size in blocks: ${SWAP_BLOCKS}" >> ${REDIRECT}
    echo "Zeroing out swap file to maximise efficiency of " \
         "compacting" >> ${REDIRECT}

    # Deactivate the swap
    swapoff ${SWAP_FILE}
    # Delete the swap file
    rm -f ${SWAP_FILE}
    # Recreate and zero out the swap file with the space required
    dd if=/dev/zero of=${SWAP_FILE} bs=1024 count=${SWAP_BLOCKS} &> \
        ${REDIRECT}
    # Set permissions to secure the swap file for RW by root only
    chmod 600 ${SWAP_FILE}
    # Set up the linux swap area in the file specifying a label to allow
    # swapon by label if required
    mkswap ${SWAP_FILE} -L 'SWAP' >> ${REDIRECT}
    # Ensure file system buffers are flushed before continuing
    sync
else
    echo "No swap configured for the system; No zeroing required" >> \
        ${REDIRECT}
fi

echo "Complete" >> ${REDIRECT}

# Ensure logging output is written to disk as the next steps in the
# shutdown process unmount the filesystems
sync


exit 0
