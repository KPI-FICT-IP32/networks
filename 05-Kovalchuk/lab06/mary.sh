#!/bin/sh
set -e

# ============================
# Configure network interfaces
# ============================
# Please note that all operations are done on em1 interface. This is due em0
# interface is used only to have internet access inside the VM
ifconfig em1 inet 10.18.1.1/24

# network between routers R1(IF1) and R2(IF2)
ifconfig vlan5 create
ifconfig vlan5 inet 10.18.51.65/26 vlan 5 vlandev em1
# network between routers R1(IF2) and R3(IF1)
ifconfig vlan7 create
ifconfig vlan7 inet 10.18.51.1/26 vlan 7 vlandev em1
# subnet with data R1(IF3)
ifconfig vlan103 create
ifconfig vlan103 inet 192.168.3.3/24 vlan 103 vlandev em1

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
hostname mary.anxolerd.net
password zebra

debug rip events
debug rip packet

router rip
version 2

network vlan5
network vlan7
network vlan103

log file /var/log/quagga/ripd.log
log stdout
EOF

cat >/usr/local/etc/quagga/zebra.conf <<EOF
hostname mary.anxolerd.net
password zebra
enable password zebra

interface vlan6
  multicast
interface vlan7
  multicast
interface vlan103
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
cat >/etc/rc.conf <<EOF
#!/bin/sh
ifconfig_em0="DHCP"
sshd_enable="YES"
hostname="mary"

ifconfig_em1="inet 10.0.1.1 netmask 255.255.255.0"
cloned_interfaces="vlan5 vlan7 vlan103"
ifconfig_vlan5="inet 10.18.51.65/26 vlan 5 vlandev em1"
ifconfig_vlan7="inet 10.18.51.1/26 vlan 7 vlandev em1"
ifconfig_vlan103="inet 192.168.3.3/24 vlan 103 vlandev em1"

quagga_enable="YES"
quagga_daemons="zebra ripd"
EOF
