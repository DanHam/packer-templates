#!/usr/bin/env bash
#
# If used without without having first installed open-vm-tools this script
# will perform a default installation of the VMware Tools package bundled
# with Workstation or Fusion
#
# If used after the open-vm-tools package has been installed, the script
# installs the vmhgfs module from the VMware tools iso.
# The installer will not overwrite any of the packages or files installed
# by open-vm-tools by default and instead only compiles and installs the
# vmhgfs module.
#
# Together with the open-vm-tools package, this allows the use of a shared
# folder accessible from both the host and guest OS while still using the
# preferred open-vm-tools package to provide the majority of host-guest
# optimisations and interactivity.
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
# In order to run the installer the following packages must be installed:
#
#   * perl
#
# In order to compile kernel modules the following packages must be
# installed:
#
#   * gcc
#   * make
#   * kernel-headers
#   * kernel-devel
#
# Since the image is typically rebuilt when kernel updates are required
# we won't need the ability to compile the VMware tools again.
# As such, with the exception of make (which is installed as part of the
# base install), these packages are removed post build and install of the
# VMware tools modules.
# The option to automatically rebuild VMware tools kernel modules when
# the kernel is upgraded is explicitly disabled.
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Configure list of packages that need to be installed
packages=" perl gcc kernel-headers kernel-devel"
# Install required package
echo "Installing packages required by the VMware tools installer..."
yum -y install ${packages} > ${redirect}

# Set the path to the perl executable
perl_bin="$(command -v perl)"
# Exit if for some reason the installation of perl failed or we fail to
# find the executable
if [ "x${perl_bin}" = "x" ]; then
    echo "ERROR: Could not locate perl. Exiting."
    exit 1
fi

# Set the path to the VMware tools iso using the environment variable
# defined in the Packer template and created on this system by Packer
vmware_iso="${VMTOOLS_ISO_PATH}"
# Exit if the environment variable is not set
if [ "x${vmware_iso}" == "x" ]; then
    echo "ERROR: Failed to set the path to the VMware Tools ISO. Exiting"
    exit 1
fi
# Exit if the iso has not been uploaded
if [ ! -e ${vmware_iso} ]; then
    echo "ERROR: Could not find VMware Tools ISO at ${vmware_iso}. Exiting"
    exit 1
fi

# Set the path to the VMware Tools configuration file
vmware_config="/etc/vmware-tools/locations"
# Create a mount point for the VMware Tools ISO avoiding any possible name
# conflicts under /tmp through use of mktemp
vmware_mnt="$(mktemp -t -d --tmpdir=/tmp vmware-mnt-XXXXXX)"
# Create a directory into which the Tools tar package will be extracted
vmware_extract="$(mktemp -t -d --tmpdir=/tmp vmware-extract-XXXXXX)"

# Mount the ISO
mount -o loop ${vmware_iso} ${vmware_mnt} -o ro
# The tools are provided as a tar.gz package on the ISO with the name of
# VMwareTools-<VERSION>.tar.gz.
# Grab the path to the package
tools_tar_path="$(find ${vmware_mnt} -iname "VMwareTools-*")"
# Now extract the tools into the required directory
tar xzf ${tools_tar_path} -C ${vmware_extract}
# Set the full path to the extracted installer package
tools_installer="${vmware_extract}/vmware-tools-distrib/vmware-install.pl"

# When the bundled VMware Tools are installed without open-vm-tools we
# need to configure the installation options
# When installed with open-vm-tools we can just run with the defaults
if ! rpm -q open-vm-tools &>/dev/null; then
    # Create a temp file to store answers for the installer
    answers_file="$(mktemp -t --tmpdir=/tmp vmware-answer-XXXXXX.txt)"
    # Output answers to the temp file
    printf "%s" "\
        # Check for missing kernel drivers?
        yes
        # Directory to install binary files?
        /usr/bin
        # Directory that contains the init directories?
        /etc/rc.d
        # Directory that contains the init scripts?
        /etc/rc.d/init.d
        # Directory in which to install daemon files?
        /usr/sbin
        # Directory in which to install the library files?
        /usr/lib/vmware-tools
        # Create the directory for library files?
        yes
        # Directory in which to install the documentation files?
        /usr/share/doc/vmware-tools
        # Create the directory for documentation files?
        yes
        # Configure VMware Tools now?
        yes
        # Overwrite open-vm-tools vmware-hgfsclient binary?
        no
        # Overwrite open-vm-tools vmhgfs-fuse binary?
        no
        # Enable the shared folders feature for Worstation/Fusion?
        yes
        # Enable automatic rebuild of VMware kernel modules?
        no
    " | sed 's/^ *//g' | egrep -v "^#|$^" > ${answers_file}
fi

# Logging for packer
if ! rpm -q open-vm-tools &>/dev/null; then
    # Full install of VMware tools from the bundled iso
    echo "Installing VMware Tools from the bundled iso..."
    echo "Configured install answers:" > ${redirect}
    while read line
    do
        echo ${line} > ${redirect}
    done < ${answers_file}
else
    # Open VM Tools with vmhgfs module from the bundled installer
    echo "Installing the VMware Tools vmhgfs module..."
fi

# Run the VMware Installer Perl script with required options
if ! rpm -q open-vm-tools &>/dev/null; then
    ${perl_bin} ${tools_installer} < ${answers_file} > ${redirect}
else
    ${perl_bin} ${tools_installer} --default > ${redirect}
fi

# Clean up
# Unmount the VMware Tools ISO
umount ${vmware_mnt}
# Remove the temp directories, ISO and answer files as required
rm -rf ${vmware_extract} ${vmware_mnt} ${vmware_iso} ${answers_file}


# Configure VMware Tools to disable the automatic rebuild of kernel
# modules post update of the kernel
echo "Preventing tools from auto rebuiling modules on kernel update..."
sed -i 's/answer AUTO_KMODS_ENABLED_ANSWER yes/answer AUTO_KMODS_ENABLED_ANSWER no/g' ${vmware_config}
sed -i 's/answer AUTO_KMODS_ENABLED yes/answer AUTO_KMODS_ENABLED no/g' ${vmware_config}

# Remove all packages (and deps) required to build and install the tools
echo "Removing all packages required to build and install the tools..."
yum -C remove -y --setopt="clean_requirements_on_remove=1" ${packages} > \
    ${redirect}

exit 0
