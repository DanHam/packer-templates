#!/usr/bin/env bash
#
# Dynamically create the packer-virt-sysprep control script using the
# settings in the Packer configuration template.
#
# The control script is executed by the packer-virt-sysprep.service unit
# file and provides the mechanism through which all other requested
# virt-sysprep style scripts are executed.
#
# By default all virt-sysprep style operations will be run unless
# explicitly disabled in the Packer configuration template. This is
# achieved by setting the environment variable that corresponds to the
# operation to something other than 'true'.
set -o errexit

# Packer logging
echo "Creating packer-virt-sysprep.service run control script..."

# The directory that is to be used to hold all packer-virt-sysprep files
# and operations scripts is specified in the Packer configuration template
# and exported as an environment variable
prefix="${PACKER_VIRT_SYSPREP_DIR}"

# Control script location. This is referenced and run by the unit file.
ctrlf="${prefix}/packer-virt-sysprep-run-ops.sh"

# Set an explict path to Bash executable to ensure our scripts run under
# bash exclusively. Note that running the 'sh' command on Debian and
# Ubuntu systems will actually start a dash shell. dash will error and
# cause us problems when it encounters bash specific commands in the
# scripts
bsh="$(command -v bash)"
if [ "x${bsh}" = "x" ]; then
    echo "ERROR: Could not enumerate path for bash executable. Exiting"
    exit 1
fi

# All virt-sysprep style operations will run by default unless explicitly
# disabled in the Packer template
: ${SYSPREP_OP_BASH_HISTORY:=true}
: ${SYSPREP_OP_CLOUD_INIT:=true}
: ${SYSPREP_OP_CRASH_DATA:=true}
: ${SYSPREP_OP_DHCP_CLIENT_STATE:=true}
: ${SYSPREP_OP_FIREWALL_RULES:=true}
: ${SYSPREP_OP_LOGFILES:=true}
: ${SYSPREP_OP_MACHINE_ID:=true}
: ${SYSPREP_OP_MAIL_SPOOL:=true}
: ${SYSPREP_OP_PACKAGE_MANAGER_CACHE:=true}
: ${SYSPREP_OP_PACKAGE_MANAGER_DB:=true}
: ${SYSPREP_OP_SSH_HOSTKEYS:=true}
: ${SYSPREP_OP_TMP_FILES:=true}
: ${SYSPREP_OP_YUM_UUID:=true}

# Generate the packer-virt-sysprep operations control script

# Script shebang
echo "#!/usr/bin/env bash" >> ${ctrlf}

# bash_history: Remove all users bash history. Remove:
#     * /home/*/.bash_history
#     * /root/.bash_history
if [ "${SYSPREP_OP_BASH_HISTORY}" = true ]; then
    script_path="${prefix}/sysprep-op-bash-history.sh"
    if [ ! -e "${script_path}" ]; then
        echo "Error: Script not found: ${script_path}. Exiting"
        exit 1
    fi
    echo "Service will run ${script_path}"
    echo "${bsh} ${script_path}" >> ${ctrlf}
fi

# cloud-init: Reinitialise cloud-init by removing run-time data and logs:
#     * /var/lib/cloud-init/*
#     * /var/log/cloud-init.log
if [ "${SYSPREP_OP_CLOUD_INIT}" = true ]; then
    script_path="${prefix}/sysprep-op-cloud-init.sh"
    if [ ! -e "${script_path}" ]; then
        echo "Error: Script not found: ${script_path}. Exiting"
        exit 1
    fi
    echo "Service will run ${script_path}"
    echo "${bsh} ${script_path}" >> ${ctrlf}
fi

# crash_data: Remove crash data generated by kexec-tools by removing:
#     * /var/crash/*
#     * /var/log/dump/*
if [ "${SYSPREP_OP_CRASH_DATA}" = true ]; then
    script_path="${prefix}/sysprep-op-crash-data.sh"
    if [ ! -e "${script_path}" ]; then
        echo "Error: Script not found: ${script_path}. Exiting"
        exit 1
    fi
    echo "Service will run ${script_path}"
    echo "${bsh} ${script_path}" >> ${ctrlf}
fi

# dhcp-client-state: Remove DHCP client release by removing:
#     * /var/lib/dhclient/*
#     * /var/lib/dhcp/*
if [ "${SYSPREP_OP_DHCP_CLIENT_STATE}" = true ]; then
    script_path="${prefix}/sysprep-op-dhcp-client-state.sh"
    if [ ! -e "${script_path}" ]; then
        echo "Error: Script not found: ${script_path}. Exiting"
        exit 1
    fi
    echo "Service will run ${script_path}"
    echo "${bsh} ${script_path}" >> ${ctrlf}
fi

# firewall-rules: Remove custom firewall rules by removing:
#     * /etc/sysconfig/iptables
#     * /etc/firewalld/services/*
#     * /etc/firewalld/zones/*
if [ "${SYSPREP_OP_FIREWALL_RULES}" = true ]; then
    script_path="${prefix}/sysprep-op-firewall-rules.sh"
    if [ ! -e "${script_path}" ]; then
        echo "Error: Script not found: ${script_path}. Exiting"
        exit 1
    fi
    echo "Service will run ${script_path}"
    echo "${bsh} ${script_path}" >> ${ctrlf}
fi

# logfiles: Remove every logfile ever created by removing:
#     # ...a ton of stuff!
if [ "${SYSPREP_OP_LOGFILES}" = true ]; then
    script_path="${prefix}/sysprep-op-logfiles.sh"
    if [ ! -e "${script_path}" ]; then
        echo "Error: Script not found: ${script_path}. Exiting"
        exit 1
    fi
    echo "Service will run ${script_path}"
    echo "${bsh} ${script_path}" >> ${ctrlf}
fi

# machine-id: Remove the local machine ID by removing content from:
#     * /etc/machine-id
#     * /var/lib/dbus/machine-id
if [ "${SYSPREP_OP_MACHINE_ID}" = true ]; then
    script_path="${prefix}/sysprep-op-machine-id.sh"
    if [ ! -e "${script_path}" ]; then
        echo "Error: Script not found: ${script_path}. Exiting"
        exit 1
    fi
    echo "Service will run ${script_path}"
    echo "${bsh} ${script_path}" >> ${ctrlf}
fi

# mail-spool: Remove email from the local mail spool directory
#     # /var/spool/mail/*
#     * /var/mail/*
if [ "${SYSPREP_OP_MAIL_SPOOL}" = true ]; then
    script_path="${prefix}/sysprep-op-mail-spool.sh"
    if [ ! -e "${script_path}" ]; then
        echo "Error: Script not found: ${script_path}. Exiting"
        exit 1
    fi
    echo "Service will run ${script_path}"
    echo "${bsh} ${script_path}" >> ${ctrlf}
fi

# package-manager-cache: Remove package manager cache by removing files
# under:
#     * /var/cache/apt/archives/
#     * /var/cache/dnf/
#     * /var/cache/yum/
#     * /var/cache/zypp*
if [ "${SYSPREP_OP_PACKAGE_MANAGER_CACHE}" = true ]; then
    script_path="${prefix}/sysprep-op-package-manager-cache.sh"
    if [ ! -e "${script_path}" ]; then
        echo "Error: Script not found: ${script_path}. Exiting"
        exit 1
    fi
    echo "Service will run ${script_path}"
    echo "${bsh} ${script_path}" >> ${ctrlf}
fi

# package-manager-db: Remove dynamically create package manager files by
# removing:
#     * /var/lib/rpm/__db.*
#     * /var/lib/apt/lists/**/*
if [ "${SYSPREP_OP_PACKAGE_MANAGER_DB}" = true ]; then
    script_path="${prefix}/sysprep-op-package-manager-db.sh"
    if [ ! -e "${script_path}" ]; then
        echo "Error: Script not found: ${script_path}. Exiting"
        exit 1
    fi
    echo "Service will run ${script_path}"
    echo "${bsh} ${script_path}" >> ${ctrlf}
fi

# ssh-hostkeys: Remove the SSH host keys in the guest by removing:
#     * /etc/ssh/*_host_*
if [ "${SYSPREP_OP_SSH_HOSTKEYS}" = true ]; then
    script_path="${prefix}/sysprep-op-ssh-hostkeys.sh"
    if [ ! -e "${script_path}" ]; then
        echo "Error: Script not found: ${script_path}. Exiting"
        exit 1
    fi
    echo "Service will run ${script_path}"
    echo "${bsh} ${script_path}" >> ${ctrlf}
fi

# tmp-files: Remove all temporary files and directories by removing:
#     * /tmp/*
#     * /var/tmp/*
if [ "${SYSPREP_OP_TMP_FILES}" = true ]; then
    script_path="${prefix}/sysprep-op-tmp-files.sh"
    if [ ! -e "${script_path}" ]; then
        echo "Error: Script not found: ${script_path}. Exiting"
        exit 1
    fi
    echo "Service will run ${script_path}"
    echo "${bsh} ${script_path}" >> ${ctrlf}
fi

# yum-uuid: Remove the yum UUID
#     * /var/lib/yum/uuid
if [ "${SYSPREP_OP_YUM_UUID}" = true ]; then
    script_path="${prefix}/sysprep-op-yum-uuid.sh"
    if [ ! -e "${script_path}" ]; then
        echo "Error: Script not found: ${script_path}. Exiting"
        exit 1
    fi
    echo "Service will run ${script_path}"
    echo "${bsh} ${script_path}" >> ${ctrlf}
fi

# Script tail
echo "exit 0" >> ${ctrlf}


# Scripts to be run by systemd unit files must have the executable bit set
chmod u+x ${ctrlf}


exit 0
