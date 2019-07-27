#!/usr/bin/env bash
#
# Remove extraneous packages
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Removing extraneous packages..."

# Packages common to Debian 9 and 10
common="avahi-autoipd
        cpp
        dictionaries-common
        discover
        discover-data
        dmidecode
        emacsen-common
        firmware-linux-free
        gcc
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
        task-english
        task-laptop
        tasksel
        tasksel-data
        wamerican"

# Packages found on Debian 9 only
debian9="cpp-6"

# Packages found on Debian 10 only
debian10="cpp-7 \
          gdbm-l10n"

# Concatenate lists to get the full package list for the given version
if [ $(cat /etc/debian_version | sed -r 's/([0-9]{1,}).*/\1/g') -lt 10 ]; then
    packages=${common}' '${debian9}
else
    packages=${common}' '${debian10}
fi

export DEBIAN_FRONTEND="noninteractive"
apt-get --ignore-missing --purge autoremove -y ${packages} > ${redirect}

exit 0
