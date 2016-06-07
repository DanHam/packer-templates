#!/usr/bin/env bash
#
# Update installed packages

# Clean the yum repository
yum clean all

# Update
yum -y update
