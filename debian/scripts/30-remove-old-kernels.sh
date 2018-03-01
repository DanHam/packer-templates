#!/usr/bin/env bash
#
# Check for and remove deprecated kernels and corresponding packages

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Logging for packer
echo "Checking for and removing old kernel packages as required..."
echo "Current kernel package is linux-image-$(uname -r)"

# Initialise list of old kernel and associated packages to remove
REMOVE=""
# All installed kernels will have a corresponding vmlinuz file under /boot
# Old and outdated kernels installed on the system can be found by
# comparing their vmlinuz files with the running kernel version
for i in $(ls /boot | grep vmlinuz | grep -v $(uname -r))
do
    # Determine the numeric version of the old kernel
    VERSION="$(echo $i | sed -e 's/vmlinuz-//g' \
                             -e 's/-rt//g' \
                             -e 's/-amd64//g' \
                             -e 's/-dbg//g' )"
    echo "Old kernel found with version: ${VERSION}"

    # Find all possible kernel image, header, and support package names for
    # the given version
    KPKG="$(apt-cache search ${VERSION} | cut -d' ' -f1 | grep ${VERSION})"
    # If any of the packages are installed add it to the list to be removed
    for PKG in ${KPKG}
    do
        if [ "x$(dpkg -l | grep ^ii | grep ${PKG})" != "x" ]; then
            REMOVE+="${PKG} "
            echo "Found deprecated package: ${PKG}" > ${REDIRECT}
        fi
    done
done

# Remove all deprecated packages
if [ "x${REMOVE}" != "x" ]; then
    echo "Removing kernel packages (and any orphaned dependancies of):"
    echo ${REMOVE} | tr -s '[:blank:]' '\n'
    apt-get --purge remove --autoremove -y ${REMOVE} > ${REDIRECT}
else
    echo "No old kernel packages found"
fi

exit 0
