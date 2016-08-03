#!/usr/bin/env bash
#
# Configure packages beneficial when running as a cloud instance

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Packer logging
echo "Configuring packages beneficial when running as a cloud instance..."

CLOUD_INIT_CONF="/etc/cloud/cloud.cfg"
CLOUD_INIT_CFGD="/etc/cloud/cloud.cfg.d"

# By default the CentOS cloud-init package disables collection of EC2
# metadata. Since the target cloud platform is Amazons EC2 we want to
# enable it
sed -i "/disable-ec2-metadata/ d" ${CLOUD_INIT_CONF}

# Since the target platform is Amazons EC2 we can speed up processing by
# only running the cloud-init code for the Amazon EC2 datasource
cat <<EOF >${CLOUD_INIT_CFGD}/90_datasources.cfg
# Configure data sources from which to pull metadata
datasource_list: [ Ec2 ]
EOF


exit 0
