#!/usr/bin/env bash
#
# Delete auto generated box Vagrantfiles and clean up
set -o errexit -o nounset

# Set verbose/quiet output based on setting configured in Packer template
[ "${DEBUG:-false}" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Exit if the env var that specifies the path to the directory containing
# the Vagrantfiles is unset or empty. PACKER_BUILDER_TYPE should always be
# set by Packer. However, exit here for safety if is is unset or empty.
[ "${VAGRANTFILE_BASE_DIR:-x}" == "x" ] || \
    [ "${PACKER_BUILDER_TYPE:-x}" == "x" ] && exit 0

# Packer logging
echo "Deleting any box Vagrantfiles generated during the run..."

# Delete the Vagrantfiles
if [ -d "${VAGRANTFILE_BASE_DIR}" ]; then
    find "${VAGRANTFILE_BASE_DIR}" -type f -name "*${PACKER_BUILDER_TYPE}" | \
        xargs -I file sh -c "echo Removing file > ${redirect}; rm -f file"
fi

# Recursively delete the directory used to house the Vagrantfiles if it now
# contains no files
if ! find "${VAGRANTFILE_BASE_DIR}" -mindepth 1 -type f -print \
    -quit 2>/dev/null | grep -q .; then
    echo "Removing empty directory '${VAGRANTFILE_BASE_DIR}'" > ${redirect}
    rm -rf "${VAGRANTFILE_BASE_DIR}"
fi

exit 0
