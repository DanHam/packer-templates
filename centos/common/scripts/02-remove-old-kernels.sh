#!/usr/bin/env bash
#
# Check for and remove old kernels and corresponding devel packages
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Checking for and removing old kernel packages as required..."

# Set the running kernel package name
echo "Current kernel package is kernel-$(uname -r)"

# Get the list of all installed kernel packages from the package manager
kpkgs="$(rpm -qa | grep ^kernel)"

# Initialise list of old kernel packages to remove
remove=""
# All installed kernels will have a corresponding vmlinuz file under /boot
# Old and outdated kernels installed on the system can be found by
# comparing their vmlinuz files with the running kernel version
for i in $(ls /boot | grep vmlinuz | grep -v $(uname -r))
do
    # Determine the version of the old kernel
    version="$(echo $i | sed 's/vmlinuz-//g')"
    # Create the corresponding kernel and devel package names
    kernel="kernel-${version}"
    devel="kernel-devel-${version}"
    # Now check if the package is installed and if so add it to the list
    # of packages to be removed from the system
    [[ "x$(echo ${kpkgs} | grep ${kernel})" != "x" ]] && remove+="${kernel} "
    [[ "x$(echo ${kpkgs} | grep ${devel})" != "x" ]] && remove+="${devel} "
done

# Remove all old kernel packages as required
if [ "x${remove}" != "x" ]; then
    echo "Removing old kernel packages: ${remove}..."
    yum -y remove ${remove} > ${redirect}
else
    echo "No old kernel packages found"
fi

exit 0
