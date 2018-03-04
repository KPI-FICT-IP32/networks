#!/bin/bash
set -e

# Check nsd configuration file
nsd-checkconf /etc/nsd/nsd.conf

# Check zone files
nsd-checkzone zone05.net. /etc/nsd/zones/zone05.net.zone
nsd-checkzone 11.25.172.in-addr.arpa. /etc/nsd/zones/11.25.172.in-addr.arpa.zone

# Start NSD
/etc/init.d/nsd start

# Run NSD at startup
rc-update add nsd
