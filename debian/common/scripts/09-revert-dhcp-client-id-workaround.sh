#!/usr/bin/env bash
#
# Revert changes made by the preseed late command to the DHCP client
# configuration as a workaround for Packer issue #8528.
# See: https://github.com/hashicorp/packer/issues/8528
set -o errexit

# Change the file back to match the original shipped with the package
conf=/etc/dhcp/dhclient.conf
sed -i -r 's/(send dhcp-client-identifier).*$/#\1 1:0:a0:24:ab:fb:9c;/' $conf

exit 0
