#!/bin/env bash

# Configure script
set -e # Stop script execution on any error
echo ""; echo "-----------------------------------------"

# Configure variables
MYHOST=agent2
MYHOSTIP="10.0.0.34"
echo "- Variables set -"

# Set system name
hostnamectl set-hostname $MYHOST
cat >> /etc/hosts <<EOF
$MYHOSTIP	$MYHOST $MYHOST.localdomain
EOF
echo "- Name set -"

# Install tools
dnf -yqe 3 install net-tools python3 epel-release
dnf -yqe 3 localinstall http://download.opensuse.org/repositories/home:/kayhayen/CentOS_8/noarch/nuitka-0.6.9.4-5.1.noarch.rpm
pip3 install icmplib > /dev/null 2>&1
echo "- Tools installed -"

# Install Application
curl -s https://packagecloud.io/install/repositories/sensu/stable/script.rpm.sh | sudo bash > /dev/null 2>&1
dnf -yq install sensu-go-agent sensu-go-cli
cat <<EOF > /etc/sensu/agent.yml
---
# Sensu agent configuration

##
# agent overview
##
name: "$MYHOST"
namespace: "default"
subscriptions:
- sla-sub

##
# agent configuration
##
backend-url:
  - "ws://10.0.0.17:8081"
cache-dir: "/var/cache/sensu/sensu-agent"
config-file: "/etc/sensu/agent.yml"
disable-assets: false
log-level: "debug" # available log levels: panic, fatal, error, warn, info, debug

# Everything below this line is configuring the agent itself, IPs should be 127.0.0.1

##
# api configuration
##
api-host: "127.0.0.1"
api-port: 3031
disable-api: false
events-burst-limit: 10
events-rate-limit: 10.0

##
# authentication configuration
##
user: "admin"
password: "password"

##
# monitoring configuration
##
deregister: false
deregistration-handler: "example_handler"
keepalive-warning-timeout: 120
keepalive-interval: 20

##
# security configuration
##
insecure-skip-tls-verify: false
redact:
  - password
  - passwd
  - pass
  - api_key
  - api_token
  - access_key
  - secret_key
  - private_key
  - secret
#trusted-ca-file: "/path/to/trusted-certificate-authorities.pem"

##
# socket configuration
##
disable-sockets: false
socket-host: "127.0.0.1"
socket-port: 3030

##
# statsd configuration
##
statsd-disable: false
statsd-event-handlers:
  - example_handler
statsd-flush-interval: 10
statsd-metrics-host: "127.0.0.1"
statsd-metrics-port: 8125
EOF

cat <<EOF > /etc/sudoers.d/sensu
sensu	ALL=NOPASSWD:/usr/bin/check-path.py	ALL
EOF

echo "- Sensu installed -"

# Install check-path.py
curl  -s "https://raw.githubusercontent.com/davetayl/Nagios-Plugins/master/check-path/check-path.py" -o /tmp/check-path.py > /dev/null 2>&1
nuitka3 --recurse-all /tmp/check-path.py -o /usr/bin/check-path.bin > /dev/null 2>&1
chmod +s /usr/bin/check-path.bin > /dev/null 2>&1
echo "- check-path.py Installed -"

# Install check-path-inf.py
curl  -s "https://raw.githubusercontent.com/davetayl/influxdb-plugins/main/check-path/check-path-inf.py" -o /tmp/check-path-inf.py > /dev/null 2>&1
nuitka3 --recurse-all /tmp/check-path-inf.py -o /usr/bin/check-path-inf.bin > /dev/null 2>&1
chmod +s /usr/bin/check-path-inf.bin > /dev/null 2>&1
echo "- check-path-inf.py Installed -"

systemctl enable --now sensu-agent
echo "- Sensu started -"


echo "-----------------------------------------"
echo "With great power comes great opportunity!"
echo "-----------------------------------------"
