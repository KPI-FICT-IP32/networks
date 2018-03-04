#!/bin/sh
# exit on errors
set -e

# Get path of currently running script
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "${SCRIPT}")

# Make common configuration
sh "${SCRIPTPATH}/common.sh"

# Master configuration
cat > /etc/nsd/nsd.conf << 'EOF'
server:
        port: 53
        do-ip4: yes
        zonesdir: "/etc/nsd/zones"
        logfile: "/var/log/nsd.log"

remote-control:
        control-enable: yes

key:
        name: "sec_key"
        algorithm: hmac-sha256
        secret: "+S244HDj17DcN81BIvHkiessdLw2iKeDmYV3JplP4EI="

pattern:
        name: "transfer-to-ns2"
        notify: 10.18.51.6 sec_key
        provide-xfr: 10.18.51.6 sec_key

zone:
        name: zone05.net
        zonefile: zone05.net.zone
        include-pattern: "transfer-to-ns2"
zone:
        name: 11.25.172.in-addr.arpa
        zonefile: 11.25.172.in-addr.arpa.zone
        include-pattern: "transfer-to-ns2"
EOF

# Generate keys for remote control
nsd-control-setup

# Run check configuration and run DNS server
sh "${SCRIPTPATH}/check-and-run.sh"
