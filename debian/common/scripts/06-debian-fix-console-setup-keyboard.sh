#!/usr/bin/env bash
#
# Fixes an issue with use of the wrong keyboard layout code. This causes
# the console-setup service to fail on Debian 9 and issue an error message
# on Debian 8. This is fixed in Debian 10.
set -o errexit

# For UK keyboard layouts the correct XKBLAYOUT is 'gb' not 'uk'
sed -i '/^XKBLAYOUT=/ s/uk/gb/g' /etc/default/keyboard
