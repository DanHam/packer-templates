#!/usr/bin/env bash
#
# Disable the system speaker... die annoying beep... DIE!!!

# Permanently blacklist the pcspkr module to disable system beeps
cat <<EOF >/etc/modprobe.d/blacklist-pcspkr.conf
# Prevent system beeps
blacklist pcspkr
EOF
