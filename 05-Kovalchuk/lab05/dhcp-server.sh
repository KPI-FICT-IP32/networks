#!/bin/sh

# ================================
# Download and install dhcp-server
# ================================
ASSUME_ALWAYS_YES=yes pkg install net/isc-dhcp43-server

# ================
# Configure server
# ================
cat >/usr/local/etc/dhcpd.conf <<EOF
# dhcpd.conf

# option definitions common to all supported networks...
option domain-name "anxolerd.net";
option domain-name-servers 10.18.49.102;

default-lease-time 300;
max-lease-time 300;

# If this DHCP server is the official DHCP server for the local
# network, the authoritative directive should be uncommented.
#authoritative;

subnet 10.18.51.0 netmask 255.255.255.0 {
  range 10.18.51.90 10.18.51.94;
  range 10.18.51.98 10.18.51.98;
  option routers 10.18.51.1;
}

host starfire {
  hardware ethernet 08:00:07:26:c0:a5;
  fixed-address 10.18.51.99;
}
EOF
