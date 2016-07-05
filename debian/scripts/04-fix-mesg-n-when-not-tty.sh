#!/usr/bin/env bash
#
# This script fixes an issue (well... non-issue really but it is annoying)
# where '==> default: stdin: is not a tty' is logged in the output when
# using the shell provisioner with Vagrant.
#
# The error is logged due to Debian (and apparently Ubuntu too) not
# checking if stdin is a TTY before running the 'mesg n' command. The
# offending command is found in the root users .profile script. The
# .profile script is run when vagrant attempts to ssh in to run the
# provisioning scripts.
#
# For full details see: https://github.com/mitchellh/vagrant/issues/1673

# Ensure stdin is a TTY before running the mesg n command
sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile
