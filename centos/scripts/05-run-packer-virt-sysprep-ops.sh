#!/usr/bin/env bash
#
# Clean and prepare the system a la virt-sysprep
#
# See:
# http://libguestfs.org/virt-sysprep.1.html and
# https://github.com/libguestfs/libguestfs/tree/master/sysprep

# bash_history: Remove all users bash history. Remove:
#     * /home/*/.bash_history
#     * /root/.bash_history

# crash_data: Remove crash data generated by kexec-tools by removing:
#     * /var/crash/*
#     * /var/log/dump/*

# dhcp-client-state: Remove DHCP client release by removing:
#     * /var/lib/dhclient/*
#     * /var/lib/dhcp/*

# firewall-rules: Remove custom firewall rules by removing:
#     * /etc/sysconfig/iptables
#     * /etc/firewalld/services/*
#     * /etc/firewalld/zones/*

# logfiles: Remove every logfile ever created by removing:
#     # ...a ton of stuff!

# machine-id: Remove the local machine ID by removing content from:
#     * /etc/machine-id
#     * /var/lib/dbus/machine-id

# mail-spool: Remove email from the local mail spool directory
#     # /var/spool/mail/*
#     * /var/mail/*

# package-manager-cache: Remove package manager cache by removing files
# under:
#     * /var/cache/apt/archives/
#     * /var/cache/dnf/
#     * /var/cache/yum/
#     * /var/cache/zypp (not implemented)

# rpm-db: Remove host-specific RPM database files by removing:
#     # /var/lib/rpm/__db.*

# ssh-hostkeys: Remove the SSH host keys in the guest by removing:
#     * /etc/ssh/*_host_*

# tmp-files: Remove all temporary files and directories by removing:
#     * /tmp/*
#     * /var/tmp/*

# yum-uuid: Remove the yum UUID
#     * /var/lib/yum/uuid
