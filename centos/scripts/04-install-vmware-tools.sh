#!/usr/bin/env bash
#
# Installs the vmhgfs module from the VMware tools iso bundled with VMware
# Workstation or Fusion. Together with the open-vm-tools package, this
# allows the use of a shared folder accessible from both the host and
# guest OS.
#
# The install of the vmhgfs module in this manner is a workaround for a
# bug in the packaging of open-vm-tools. Currently the vmhgfs module is
# missing from open-vm-tools and has been wronly placed in the
# open-vm-tools-desktop package instead.
# See:
# https://bugs.launchpad.net/ubuntu/+source/open-vm-tools/+bug/1551558
# https://github.com/bzed/pkg-open-vm-tools/issues/4
#
# Once the fix for the bug has made it's way into the distro repositories
# installation of the vmhgfs module using this method will not be
# necessary - a simple install of the open-vm-tools package will be all
# that is required to use shared folders
#
# When used to provide just the vmhgfs module the VMware tools installer
# must be used after the install of open-vm-tools. The installer will not
# overwrite any of the packages or files installed by open-vm-tools by
# default and instead only compiles and installs the missing vmhgfs module
#
# In order to run the installer the following packages must be installed:
#
#   * perl
#
# In order to compile the vmhgfs module the following packages must be
# installed:
#
#   * gcc
#   * make
#   * kernel-headers
#   * kernel-devel
#

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Install required package
echo "Installing packages required by the VMware tools installer..."
yum -y install perl gcc make kernel-headers kernel-devel > $REDIRECT

# Set the path to the perl executable
PERL="$(which perl)"
# Exit if for some reason the installation of perl failed or we fail to
# find the executable
if [ "x$PERL" == "x" ]; then
    echo "ERROR: Could not locate perl. Exiting."
    exit -1
fi

# Set the path to the VMware tools iso using the environment variable
# defined in the Packer template and created on this system by Packer
VMWARE_ISO="$VMTOOLS_ISO_PATH"
# Exit if the environment variable is not set
if [ "x$VMWARE_ISO" == "x" ]; then
    echo "ERROR: Failed to set the path to the VMware Tools ISO. Exiting"
    exit -1
fi

# Set the path to the VMware Tools configuration file
VMWARE_CONFIG="/etc/vmware-tools/locations"


# Create a mount point for the VMware Tools ISO avoiding any possible name
# conflicts under /tmp through use of mktemp
VMWARE_MNT="$(mktemp -t -d --tmpdir=/tmp vmware-mnt-XXXXXX)"
# Create a directory into which the Tools tar package will be extracted
VMWARE_EXTRACT="$(mktemp -t -d --tmpdir=/tmp vmware-extract-XXXXXX)"

# Mount the ISO
mount -o loop $VMWARE_ISO $VMWARE_MNT -o ro
# The tools are provided as a tar.gz package on the ISO with the name of
# VMwareTools-<VERSION>.tar.gz.
# Grab the path to the package
TOOLS_TAR="$(find $VMWARE_MNT -iname "VMwareTools-*")"

# Now extract the tools into the required directory
tar xzf $TOOLS_TAR -C $VMWARE_EXTRACT
# Set the full path to the extracted installer package
VMWARE_INSTALLER="$VMWARE_EXTRACT/vmware-tools-distrib/vmware-install.pl"

# Run the VMware Installer Perl script accepting all defaults
echo "Installing the VMware Tools vmhgfs module..."
$PERL $VMWARE_INSTALLER --default > $REDIRECT


# Clean up
# Unmount the VMware Tools ISO
umount $VMWARE_MNT
# Remove the temp directories and ISO
rm -rf $VMWARE_EXTRACT $VMWARE_MNT $VMWARE_ISO


# Configure VMware Tools to automatically rebuild kernel modules post
# update of the kernel
echo "Configuring VMware tools to rebuild modules upon kernel update..."
sed -i.bak 's/answer AUTO_KMODS_ENABLED_ANSWER no/answer AUTO_KMODS_ENABLED_ANSWER yes/g' $VMWARE_CONFIG
sed -i 's/answer AUTO_KMODS_ENABLED no/answer AUTO_KMODS_ENABLED yes/g' $VMWARE_CONFIG

exit 0
