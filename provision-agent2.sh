#!/usr/bin/env bash

# Configure script
set -e # Stop script execution on any error
echo ""; echo "-----------------------------------------"

# Configure variables
MYHOST=agent1
echo "- Variables set -"

# Set system name
hostnamectl set-hostname $MYHOST
cat >> /etc/hosts <<EOF
10.0.0.18	$MYHOST $MYHOST.localdomain
EOF
echo "- Name set -"

# Install tools
dnf -yqe 3 install net-tools
echo "- Tools installed -"

# Install Application
curl -s https://packagecloud.io/install/repositories/sensu/stable/script.rpm.sh | sudo bash
dnf -yqe 3 install sensu-go-agent sensu-go-cli
cat <<EOF > /etc/sensu/agent.yml
---
# Sensu agent configuration

##
# agent overview
##
name: "$MYHOST"
namespace: "default"

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

echo "- Sensu installed -"

service sensu-agent start
echo "- Sensu started -"


echo "-----------------------------------------"
echo "With great power comes great opportunity!"
echo "-----------------------------------------"