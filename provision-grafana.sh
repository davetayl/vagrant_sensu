#!/usr/bin/env bash

# Configure script
set -e # Stop script execution on any error
echo ""; echo "-----------------------------------------"

# Configure variables
MYHOST=gafana
MYHOSIP="10.0.0.19"
echo "- Variables set -"

# Set system name
hostnamectl set-hostname $MYHOST
cat >> /etc/hosts <<EOF
$MYHOSTIP	$MYHOST $MYHOST.localdomain
EOF
echo "- Name set -"

# Install tools
dnf -yqe 3 install net-tools
echo "- Tools installed -"

# Install Application
dnf -yqe 3 localinstall https://dl.grafana.com/oss/release/grafana-7.1.1-1.x86_64.rpm
systemctl enable --now grafana-server
echo "- Grafana installed and running -"
