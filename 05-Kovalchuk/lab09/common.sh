#!/bin/sh
set -e

# OS Info:
# Alpine Linux for virtual boxes, installed with setup-alpine script
# HDD: 750MB
# Internal networks

# Script is intended to run as root user

# Setup DNS server
apk add nsd

# Openssl is required to setup remote control
apk add openssl

# Install diagnostic utilities
apk add bind-tools

echo "Create directory where zone files will be stored..."
mkdir -p /etc/nsd/zones/

# Now create zone files, which is going to be the same on both
# master and slave
echo "Configuring forward zone..."
cat > /etc/nsd/zones/zone05.net.zone << 'EOF'
$ORIGIN zone05.net.

@   IN  SOA ns1.zone05.net. admin.zone05.net.   (
        1       ; serial
        6h      ; refresh after 6 hrs
        1h      ; retry after 1 hr
        1w      ; expire after 1 week
        1d      ; minimum ttl 1 day
        )

        IN  NS      ns1.zone05.net.
        IN  NS      ns2.zone05.net.

        IN  MX  10  mail.zone05.net.

; Network nodes:
alpha   IN  A       172.25.11.10
beta    IN  A       172.25.11.20
gamma   IN  A       172.25.11.30
delta   IN  A       172.25.11.40
omega   IN  A       172.25.11.50

; Canonical names for network nodes
srv-01  IN  CNAME   alpha
srv-02  IN  CNAME   beta
srv-03  IN  CNAME   gamma
srv-04  IN  CNAME   delta
srv-05  IN  CNAME   omega
EOF


echo "Configuring reverse zone..."
cat > /etc/nsd/zones/11.25.172.in-addr.arpa.zone << 'EOF'
11.25.172.in-addr.arpa.  IN  SOA ns1.zone05.net. admin.zone05.net.   (
        1       ; serial
        6h      ; refresh after 6 hrs
        1h      ; retry after 1 hr
        1w      ; expire after 1 week
        1d      ; minimum ttl 1 day
        )
        
        IN  NS      ns1.zone05.net.
        IN  NS      ns2.zone05.net.

10      IN  PTR     alpha.zone05.net.
20      IN  PTR     beta.zone05.net.
30      IN  PTR     gamma.zone05.net.
40      IN  PTR     delta.zone05.net.
50      IN  PTR     omega.zone05.net.
EOF


echo "Done"
