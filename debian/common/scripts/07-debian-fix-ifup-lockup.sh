#!/usr/bin/env bash
#
# Fixes an issue where, under certain circumstances, ifup locks up when
# trying to obtain an IP address via DHCP. The issue is somewhat transient
# and so probably indicates a race somewhere in the processes that bring up
# an interface.
# Most noticably this issue affected Packer's virtualbox-ovf builder. The
# issue was not seen using the same ovf/box with Vagrant.
set -o errexit

# Give networking a chance to settle prior to bringing up any network
# interface using DHCP. This prevents the dhclient scripts from locking up
# the ifup process
sed -i -E '/^iface (en|eth).*dhcp.*/a\    pre-up sleep 2' \
    /etc/network/interfaces

exit 0
