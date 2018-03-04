#!/bin/sh
set -e

# Get path of currently running script
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "${SCRIPT}")

# Make common configuration
sh "${SCRIPTPATH}/common.sh"

# Slave configuration
cat > /etc/nsd/nsd.conf << 'EOF'
server:
        port: 53
        do-ip4: yes
        zonesdir: "/etc/nsd/zones"
        logfile: "/var/log/nsd.log"

key:
        name: "sec_key"
        algorithm: hmac-sha256
        secret: "+S244HDj17DcN81BIvHkiessdLw2iKeDmYV3JplP4EI="

pattern:
        name: "transfer-from-ns1"
        allow-notify: 10.18.51.5 sec_key
        request-xfr: AXFR 10.18.51.5 sec_key

zone:
        name: zone05.net
        zonefile: zone05.net.zone
        include-pattern: "transfer-from-ns1"
zone:
        name: 11.25.172.in-addr.arpa
        zonefile: 11.25.172.in-addr.arpa.zone
        include-pattern: "transfer-from-ns1"
EOF

# Run check configuration and run DNS server
sh "${SCRIPTPATH}/check-and-run.sh"
