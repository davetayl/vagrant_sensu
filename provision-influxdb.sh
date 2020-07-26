#!/usr/bin/env bash

# Configure script
set -e # Stop script execution on any error
echo ""; echo "-----------------------------------------"

# Configure variables
MYHOST=influxdb
MYHOSIP="10.0.0.18"
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
firewall-cmd --permanent --add-port=8086/tcp
firewall-cmd --reload
echo "- Firewall Updated -"


# Install InfluxDB
dnf -yqe 3 localinstall https://dl.influxdata.com/influxdb/releases/influxdb-1.8.1.x86_64.rpm
echo "- InfluxDB Installed -"


# Configure InfluxDB for Sensu
cat <<EOF > /etc/influxdb/influxdb.conf
# Bind address to use for the RPC service for backup and restore.
  bind-address = "127.0.0.1:8088"

[meta]
  # Where the metadata/raft database is stored
  dir = "/var/lib/influxdb/meta"

  logging-enabled = true


[data]
  # The directory where the TSM storage engine stores TSM files.
  dir = "/var/lib/influxdb/data"

  # The directory where the TSM storage engine stores WAL files.
  wal-dir = "/var/lib/influxdb/wal"

  series-id-set-cache-size = 100


[coordinator]

[retention]


[shard-precreation]

[monitor]

###
### [http]
###
### Controls how the HTTP endpoints are configured. These are the primary
### mechanism for getting data into and out of InfluxDB.
###

[http]
  # Determines whether HTTP endpoint is enabled.
  enabled = true

  # Determines whether the Flux query endpoint is enabled.
  flux-enabled = false

  # Determines whether the Flux query logging is enabled.
  flux-log-enabled = false

  # The bind address used by the HTTP service.
  bind-address = ":8086"

  # Determines whether user authentication is enabled over HTTP/HTTPS.
  auth-enabled = false

  # The default realm sent back when issuing a basic auth challenge.
  realm = "InfluxDB"

  # Determines whether HTTP request logging is enabled.
  log-enabled = true

  # Determines whether the HTTP write request logs should be suppressed when the log is enabled.
  suppress-write-log = false

  # Determines whether HTTPS is enabled.
  # https-enabled = false

  # The SSL certificate to use when HTTPS is enabled.
  # https-certificate = "/etc/ssl/influxdb.pem"

  # Use a separate private key location.
  # https-private-key = ""

###
### [logging]
###
### Controls how the logger emits logs to the output.
###

[logging]
  # Determines which log encoder to use for logs. Available options
  # are auto, logfmt, and json. auto will use a more a more user-friendly
  # output format if the output terminal is a TTY, but the format is not as
  # easily machine-readable. When the output is a non-TTY, auto will use
  # logfmt.
  # format = "auto"

  # Determines which level of logs will be emitted. The available levels
  # are error, warn, info, and debug. Logs that are equal to or above the
  # specified level will be emitted.
  # level = "info"

  # Suppresses the logo output that is printed when the program is started.
  # The logo is always suppressed if STDOUT is not a TTY.
  # suppress-logo = false


[subscriber]
  # Determines whether the subscriber service is enabled.
  # enabled = true

  # The default timeout for HTTP writes to subscribers.
  # http-timeout = "30s"

  # Allows insecure HTTPS connections to subscribers.  This is useful when testing with self-
  # signed certificates.
  # insecure-skip-verify = false

  # The path to the PEM encoded CA certs file. If the empty string, the default system certs will be used
  # ca-certs = ""

  # The number of writer goroutines processing the write channel.
  # write-concurrency = 40

  # The number of in-flight writes buffered in the write channel.
  # write-buffer-size = 1000


###
### [[graphite]]
###
### Controls one or many listeners for Graphite data.
###

[[graphite]]
  # Determines whether the graphite endpoint is enabled.
  # enabled = false
  # database = "graphite"
  # retention-policy = ""
  # bind-address = ":2003"
  # protocol = "tcp"
  # consistency-level = "one"

  # These next lines control how batching works. You should have this enabled
  # otherwise you could get dropped metrics or poor performance. Batching
  # will buffer points in memory if you have many coming in.

  # Flush if this many points get buffered
  # batch-size = 5000

  # number of batches that may be pending in memory
  # batch-pending = 10

  # Flush at least this often even if we haven't hit buffer limit
  # batch-timeout = "1s"

  # UDP Read buffer size, 0 means OS default. UDP listener will fail if set above OS max.
  # udp-read-buffer = 0

  ### This string joins multiple matching 'measurement' values providing more control over the final measurement name.
  # separator = "."

  ### Default tags that will be added to all metrics.  These can be overridden at the template level
  ### or by tags extracted from metric
  # tags = ["region=us-east", "zone=1c"]

  ### Each template line requires a template pattern.  It can have an optional
  ### filter before the template and separated by spaces.  It can also have optional extra
  ### tags following the template.  Multiple tags should be separated by commas and no spaces
  ### similar to the line protocol format.  There can be only one default template.
  # templates = [
  #   "*.app env.service.resource.measurement",
  #   # Default template
  #   "server.*",
  # ]

[continuous_queries]
  # Determines whether the continuous query service is enabled.
  # enabled = true

  # Controls whether queries are logged when executed by the CQ service.
  # log-enabled = true

  # Controls whether queries are logged to the self-monitoring data store.
  # query-stats-enabled = false

  # interval for how often continuous queries will be checked if they need to run
  # run-interval = "1s"

[tls]
  # Determines the available set of cipher suites. See https://golang.org/pkg/crypto/tls/#pkg-constants
  # for a list of available ciphers, which depends on the version of Go (use the query
  # SHOW DIAGNOSTICS to see the version of Go used to build InfluxDB). If not specified, uses
  # the default settings from Go's crypto/tls package.
  # ciphers = [
  #   "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305",
  #   "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305",
  # ]

  # Minimum version of the tls protocol that will be negotiated. If not specified, uses the
  # default settings from Go's crypto/tls package.
  # min-version = "tls1.2"

  # Maximum version of the tls protocol that will be negotiated. If not specified, uses the
  # default settings from Go's crypto/tls package.
  # max-version = "tls1.3"
EOF



systemctl enable --now influxdb

echo "- InfluxDB configured and running -"