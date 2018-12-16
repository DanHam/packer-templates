#!/usr/bin/env bash
#
# Password protect the GRUB bootloader and set timeout

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Configuring the GRUB bootloader..."

# Password protect GRUB
cat << EOF >> /etc/grub.d/40_custom
# Configure password protection for the GRUB bootloader menu
set superusers="debadmin"
password_pbkdf2 debadmin grub.pbkdf2.sha512.10000.609F3A0006395E86726E492CA5A057D38F06E91C99B2326FBFD79EBC6285EF6C355276BE194C982786D1979901055C1DB0555900FF831C78765FD2E16A7616AF.C24E2EFD5E75E5A3BDF6A22D7D845A8CF94C4795E77BDF50BED4680821F94ADD0C5E04749DEBE2E88EF0B8561678B7BE39913D0724896B9ADA3A7173DE60A712
EOF

# Ensure booting of menu entries is unprotected. Only modifications will
# require a password, otherwise the system will boot normally.
sed -i \
'/^CLASS/ {/unrestricted/ !s/CLASS="\(.*\)"/CLASS="\1 --unrestricted"/g}' \
/etc/grub.d/10_linux

# Configure the number of seconds to display the GRUB bootloader menu
# A timeout of zero seconds means the menu will not be displayed
sed -i "/^GRUB_TIMEOUT/ s/=.*/=0/" /etc/default/grub

# Update grub
update-grub &> $REDIRECT

exit 0
