#!/usr/bin/env bash
#
# Check for and remove deprecated kernels and corresponding packages
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "${DEBUG:-false}" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Checking for and removing old kernel packages as required..."
echo "Current kernel package is linux-image-$(uname -r)"

# Initialise list of old kernel and associated packages to remove
remove=""
# All installed kernels will have a corresponding vmlinuz file under /boot
# Old and outdated kernels installed on the system can be found by
# comparing their vmlinuz files with the running kernel version
for i in $(ls /boot | grep vmlinuz | grep -v $(uname -r))
do
    # Determine the numeric version of the old kernel
    version="$(echo $i | sed -e 's/vmlinuz-//g' \
                             -e 's/-rt//g' \
                             -e 's/-amd64//g' \
                             -e 's/-dbg//g' )"
    echo "Old kernel found with version: ${version}"

    # Find all possible kernel image, header, and support package names for
    # the given version
    kpkg="$(apt-cache search ${version} | cut -d' ' -f1 | grep ${version})"
    # If any of the packages are installed add it to the list to be removed
    for pkg in ${kpkg}
    do
        if dpkg -l | grep ^ii | awk '{print $2}' | \
            grep "${pkg}" &>/dev/null; then
            remove+="${pkg} "
            echo "Found deprecated package: ${pkg}" > ${redirect}
        fi
    done
done

# Remove all deprecated packages
if [ "x${remove}" != "x" ]; then
    echo "Removing kernel packages (and any orphaned dependancies of):"
    echo ${remove} | tr -s '[:blank:]' '\n'
    apt-get --purge autoremove -y ${remove} > ${redirect}
else
    echo "No old kernel packages found"
fi

exit 0
