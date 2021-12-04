#!/usr/bin/env bash
#
# Remove extraneous packages
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "${DEBUG:-false}" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Removing extraneous packages..."

# Extraneous packages list
list="avahi-autoipd
      binutils
      binutils-common
      binutils-x86-64-linux-gnu
      console-setup
      console-setup-linux
      cpp
      cpp-6
      cpp-7
      cpp-10
      dictionaries-common
      discover
      discover-data
      dmidecode
      emacsen-common
      firmware-linux-free
      gcc
      gdbm-l10n
      iamerican
      ibritish
      ienglish-common
      installation-report
      ispell
      laptop-detect
      libdiscover2
      libusb-0.1-4
      make
      os-prober
      perl
      task-english
      task-laptop
      tasksel
      tasksel-data
      util-linux-locales
      wamerican
      xkb-data"

# Build a list of unwanted packages that are installed and remove
packages=()
for package in ${list}
do
    if dpkg -s "${package}" &>/dev/null; then
        echo "Found unwanted package: ${package}" > ${redirect}
        packages+=("${package}")
    fi
done

if [ ${#packages[@]} -gt 0 ]; then
    echo ""
    echo "Removing the following packages:" > ${redirect}
    echo "${packages[@]}" > ${redirect}

    export DEBIAN_FRONTEND="noninteractive"
    apt-get --purge autoremove -y "${packages[@]}" > ${redirect}
else
    echo "No unwanted packages found" > ${redirect}
fi

exit 0
