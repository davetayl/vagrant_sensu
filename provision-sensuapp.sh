#!/usr/bin/env bash

# Configure script
set -e # Stop script execution on any error
echo ""; echo "-----------------------------------------"

# Configure variables
MYHOST=sensuapp
MYHOSIP="10.0.0.17"
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

# Configure firewall
systemctl enable --now firewalld.service
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=3000/tcp
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --add-port=8081/tcp
firewall-cmd --reload
echo "- Firewall Updated -"

# Install Application
curl -s https://packagecloud.io/install/repositories/sensu/stable/script.rpm.sh | sudo bash #> /dev/null 2>&1
dnf -yqe 3 install sensu-go-cli sensu-go-backend sensu-go-agent #> /dev/null 2>&1
curl -L https://docs.sensu.io/sensu-go/latest/files/backend.yml -o /etc/sensu/backend.yml #> /dev/null 2>&1
echo "- Sensu installed -"

# Start application
systemctl start sensu-backend > /dev/null 2>&1
export SENSU_BACKEND_CLUSTER_ADMIN_USERNAME=admin
export SENSU_BACKEND_CLUSTER_ADMIN_PASSWORD=password
sensu-backend init
sensuctl configure -n --url http://127.0.0.1:8080 --username admin --password password --format tabular
echo "- Sensu started -"

# Configure InfluxDB integration
sensuctl asset add sensu/sensu-influxdb-handler:3.1.2 -r influxdb-handler

# sensuctl handler create influx-db \
# --type pipe \
# --command "sensu-influxdb-handler -d sensu" \
# --env-vars "INFLUXDB_ADDR=http://10.0.0.18:8086, INFLUXDB_USER=sensu, INFLUXDB_PASS=password" \
# --runtime-assets influxdb-handler

# sensuctl check set-output-metric-handlers collect-metrics influx-db
# sensu-agent start --statsd-event-handlers influx-db
echo "- InfluxDB Configured -"


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