#!/usr/bin/env bash
#
# Auto generate box Vagrantfiles from template variables and user files
#
# By default a simple Vagrantfile is created with just the box url.
#
# All custom values are set in the Packer template and injected into the
# build environment as environment variables. Use is also made of the
# default environment variables set by Packer.
#
# Custom Vagrantfile snippets can be incorporated into the file by placing
# the snippet in a file under the files/template_name directory. The
# filename should have a suffix comprised of the Packer build type and
# '.snippet'. Optionally, the filename can include a number before the
# .snippet suffix to allow ordering of multiple snippets.
# As an example, to include several snippet in a specific order, for a
# template named debian-9-x86_64, being built by the vmware-iso builder,
# and the Vagrantfile base directory set to 'files', the files would need
# to be created with the following path:
#
# files/debian-9-x86_64/Vagrantfile.vmware-iso.00.snippet
# files/debian-9-x86_64/Vagrantfile.vmware-iso.01.snippet
#
# The script will automatically indent all of the snippets contents by two
# spaces. Any indentation and spacing within the snippet itself will be
# preserved.
set -o errexit -o nounset

# Set verbose/quiet output based on setting configured in Packer template
[ "${DEBUG:-false}" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Packer logging
echo "Generating Vagrantfiles for inclusion in the Vagrant box..."

# Configure required vars using default and custom env vars injected by Packer
wd="${VAGRANTFILE_BASE_DIR}/${TEMPLATE}"
vagrantfile="${wd}/${VAGRANTFILE_NAME}"
vagrantcloud_boxname="${VAGRANT_CLOUD_ORG}/${TEMPLATE}"

# Create the directory if required
[ ! -d "${wd}" ] && mkdir -p "${wd}"

# Head: Write out file mode or file type hints
cat <<EOF > "${vagrantfile}"
# -*- mode: ruby -*-
# vi: set ft=ruby :
EOF


# Write out the head of the Vagrantfile and box name
echo "Setting box name in Vagrantfile to ${vagrantcloud_boxname}" > ${redirect}
cat <<EOF >> "${vagrantfile}"
Vagrant.configure(2) do |config|
  config.vm.box = '${vagrantcloud_boxname}'
EOF

# Set the communicator based on the setting configured in the Packer
# template. If unset default to ssh
communicator="${COMMUNICATOR:-ssh}"

# Set the box user name from the setting configured in the Packer template
if [ "${BOX_USERNAME:-x}" != "x" ]; then
    echo "Setting box username to ${BOX_USERNAME}" > ${redirect}
    printf "%s" "
      config.${communicator}.username = '${BOX_USERNAME}'
    " | sed 's/^ \{4\}//g' >> "${vagrantfile}"
fi

# Set box users password if configured in the Packer template and this is a
# Windows build (communicator is winrm). *nix instances should use ssh key
# based authentication
if [ "${BOX_USERNAME:-x}" != "x" ] && [ "${BOX_USERPASSWD:-x}" != "x" ] && \
   [ "${communicator}" = "winrm" ]; then
    echo "Setting box user password to ${BOX_USERPASSWD}" > ${redirect}
    printf "%s" "\
      config.${communicator}.password = '${BOX_USERPASSWD}'
    " | sed 's/^ \{4\}//g' >> "${vagrantfile}"
fi

# Incorporate custom settings and fixes from all relevant Vagrantfile snippets
while IFS= read -r -d '' snippet; do
    echo "Incorporating ${snippet} into box Vagrantfile" > ${redirect}
    # Insert blank line
    echo "" >> "${vagrantfile}"
    # Indent all except blank lines by two spaces
    cat "${snippet}" | sed -E '/^$/ !s/(.*)/  \1/g' >> "${vagrantfile}"
done < <(find ${wd} -type f \
             -name "*${PACKER_BUILDER_TYPE}*.snippet" \
             -print0 | sort -z)

# Write out the tail of the Vagrantfile
echo "end" >> ${vagrantfile}

exit 0
