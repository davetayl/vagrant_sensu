#!/bin/env bash

# Configure script
set -e # Stop script execution on any error
echo ""; echo "-----------------------------------------"

# Configure variables
MYHOST=sensuapp
MYHOSTIP="10.0.0.17"
echo "- Variables set -"

# Set system name
hostnamectl set-hostname $MYHOST
cat >> /etc/hosts <<EOF
$MYHOSTIP	$MYHOST $MYHOST.localdomain
EOF
echo "- Name set -"

# Install tools
dnf -yqe 3 install net-tools python3
echo "- Tools installed -"

# Configure firewall
systemctl enable --now firewalld.service
firewall-cmd --permanent --add-service=http > /dev/null 2>&1
firewall-cmd --permanent --add-service=https > /dev/null 2>&1
firewall-cmd --permanent --add-port=3000/tcp > /dev/null 2>&1
firewall-cmd --permanent --add-port=8080/tcp > /dev/null 2>&1
firewall-cmd --permanent --add-port=8081/tcp > /dev/null 2>&1
firewall-cmd --reload
echo "- Firewall Updated -"

# Install Application
echo "- Install Sensu repos -"
curl https://packagecloud.io/install/repositories/sensu/stable/script.rpm.sh | sudo bash > /dev/null 2>&1
echo "- Install sensu -"
dnf -yqe 3 install sensu-go-cli sensu-go-backend sensu-go-agent
echo "- Load backend config -"
curl -L https://docs.sensu.io/sensu-go/latest/files/backend.yml -o /etc/sensu/backend.yml > /dev/null 2>&1
echo "- Sensu installed -"

# Start application
systemctl start sensu-backend > /dev/null 2>&1
export SENSU_BACKEND_CLUSTER_ADMIN_USERNAME=admin
export SENSU_BACKEND_CLUSTER_ADMIN_PASSWORD=password
sensu-backend init
sensuctl configure -n --url http://127.0.0.1:8080 --username admin --password password --format tabular
# sensuctl asset add nixwiz/sensu-check-status-metric-mutator
# mutator create status-metric --namespace default -c "sensu-check-status-metric-mutator" -r "nixwiz/sensu-check-status-metric-mutator"
sensuctl asset add sensu/sensu-influxdb-handler
# Create Check
sensuctl check create check-path -c "check-path.bin -t 3 8.8.8.8" -s "sla-sub" -i "10" 
sensuctl check set-output-metric-format check-path nagios_perfdata
# Create Debug handler
sensuctl handler create debug --type pipe --command "cat | python3 -m json.tool > /var/log/sensu/debug-event.json"
sensuctl check  set-handlers check-path debug
echo "- Sensu started -"

# Configure InfluxDB integration
sensuctl asset add sensu/sensu-influxdb-handler:3.1.2 -r influxdb-handler

 sensuctl handler create influx-db \
 --type pipe \
 --command "sensu-influxdb-handler -d sensu" \
 --env-vars "INFLUXDB_ADDR=http://10.0.0.18:8086, INFLUXDB_USER=sensu, INFLUXDB_PASS=password" \
 --runtime-assets influxdb-handler \
 --mutator status-metric

 sensuctl check set-output-metric-handlers check-path influx-db
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