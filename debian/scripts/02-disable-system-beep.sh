#!/usr/bin/env bash
#
# Disable system beeps... die annoying beep... DIE!!!

# Blacklist the pcspkr and snd_pcsp modules to disable system beeps
cat <<EOF >/etc/modprobe.d/disable_system_beeps.conf
# Prevent system beeps
blacklist pcspkr
blacklist snd_pcsp
EOF
