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

subnet 10.18.51.0 netmask 255.255.255.0 {
  range 10.18.51.90 10.18.51.94;
  range 10.18.51.98 10.18.51.98;
  option routers 10.18.51.1;
}

host polar.anxolerd.net {
  fixed-address 10.18.51.99;
}
EOF

# Create empty leases database
touch /var/db/dhcpd.leases

# ========
# Test run
# ========

ifconfig em1 10.18.51.100/24
service isc-dhcpd onestart

# =====================
# Run server on startup
# =====================
cat >/etc/rc.conf <<EOF
#!/bin/sh
ifconfig_em0="DHCP"

# The following two are an important lines
ifconfig_em1="inet 10.18.51.100 netmask 255.255.255.0"
dhcpd_enable="YES"

sshd_enable="YES"
hostname="monica"
EOF
