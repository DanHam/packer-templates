#!/usr/bin/env bash
#
# Check for and remove old kernels and corresponding devel packages

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Logging for packer
echo "Checking for and removing old kernel packages as required..."

# Set the running kernel package name
echo "Current kernel package is kernel-$(uname -r)"

# Get the list of all installed kernel packages from the package manager
KPKGS="$(rpm -qa | grep ^kernel)"

# Initialise list of old kernel packages to remove
REMOVE=""
# All installed kernels will have a corresponding vmlinuz file under /boot
# Old and outdated kernels installed on the system can be found by
# comparing their vmlinuz files with the running kernel version
for i in $(ls /boot | grep vmlinuz | grep -v $(uname -r))
do
    # Determine the version of the old kernel
    VERSION="$(echo $i | sed 's/vmlinuz-//g')"
    # Create the corresponding kernel and devel package names
    KERNEL="kernel-$VERSION"
    DEVEL="kernel-devel-$VERSION"
    # Now check if the package is installed and if so add it to the list
    # of packages to be removed from the system
    [[ "x$(echo $KPKGS | grep $KERNEL)" != "x" ]] && REMOVE+="$KERNEL "
    [[ "x$(echo $KPKGS | grep $DEVEL)" != "x" ]] && REMOVE+="$DEVEL "
done

# Remove all old kernel packages as required
if [ "x$REMOVE" != "x" ]; then
    echo "Removing old kernel packages: $REMOVE..."
    yum -y remove $REMOVE > $REDIRECT
else
    echo "No old kernel packages found"
fi

exit 0
