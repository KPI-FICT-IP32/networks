#!/bin/sh
set -e

# ============================
# Configure network interfaces
# ============================
# Please note that all operations are done on em1 interface. This is due em0
# interface is used only to have internet access inside the VM
ifconfig em1 inet 10.18.1.3/24

# network between routers R1(IF1) and R3(IF2)
ifconfig vlan7 create
ifconfig vlan7 inet 10.18.51.2/26 vlan 7 vlandev em1
# network between routers R3(IF2) and R2(IF1)
ifconfig vlan6 create
ifconfig vlan6 inet 10.18.51.130/26 vlan 6 vlandev em1
# subnet with data R2(IF3)
ifconfig vlan303 create
ifconfig vlan303 inet 192.168.9.3/24 vlan 303 vlandev em1

# ==============
# Install quagga
# ==============
ASSUME_ALWAYS_YES=yes pkg install quagga

# ========================
# Create RIP configuration
# ========================
mkdir -p /usr/local/etc/quagga
mkdir -p /var/log/quagga
chown -R quagga:quagga /var/log/quagga

cat >/usr/local/etc/quagga/ripd.conf <<EOF
hostname liza.anxolerd.net
password zebra

debug rip events
debug rip packet

router rip
version 2
redistribute connected

network vlan5
network vlan7
network vlan303

log file /var/log/quagga/ripd.log
log stdout
EOF

cat >/usr/local/etc/quagga/zebra.conf <<EOF
hostname liza.anxolerd.net
password zebra
enable password zebra

interface vlan5
  multicast

interface vlan7
  multicast

interface vlan303
  multicast

log file /var/log/quagga/zebra.log
EOF

# ========
# Test run
# ========
zebra & ripd
killall -9 zebra

# =============================
# Run all the things on startup
# =============================
# TODO: write /etc/rc.conf
