#!/usr/bin/env bash

# Configure script
set -e # Stop script execution on any error
echo ""; echo "-----------------------------------------"

# Configure variables
MYHOST=sensuapp
echo "- Variables set -"

# Set system name
hostnamectl set-hostname $MYHOST
cat >> /etc/hosts <<EOF
10.0.0.17	$MYHOST $MYHOST.localdomain
EOF
echo "- Name set -"

# Install tools
dnf -yqe 3 install net-tools 
echo "- Tools installed -"

# Install Application
curl -s https://packagecloud.io/install/repositories/sensu/stable/script.rpm.sh | sudo bash #> /dev/null 2>&1
dnf -yqe 3 install sensu-go-agent sensu-go-cli sensu-go-backend #> /dev/null 2>&1
curl -L https://docs.sensu.io/sensu-go/latest/files/backend.yml -o /etc/sensu/backend.yml #> /dev/null 2>&1
curl -L https://github.com/davetayl/vagrant_sensu/blob/master/agent.yml -o /etc/sensu/agent.yml
echo "- Sensu installed -"

# Start application
systemctl start sensu-backend > /dev/null 2>&1
export SENSU_BACKEND_CLUSTER_ADMIN_USERNAME=admin
export SENSU_BACKEND_CLUSTER_ADMIN_PASSWORD=password
sensu-backend init
service sensu-agent start
echo "- Sensu started -"

echo "-----------------------------------------"
echo "With great power comes great opportunity!"
echo "-----------------------------------------"
echo ""
echo "The install guide can be found at:-"
echo "https://docs.sensu.io/sensu-go/latest/installation/install-sensu/"
echo ""
echo "-----------------------------------------"
echo "You may now log into Sensu by browsing to http://127.0.0.1"
echo "Username: admin"
echo "Password: password"