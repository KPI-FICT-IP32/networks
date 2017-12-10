#!/bin/sh
set -e

# ============================
# Configure network interfaces
# ============================
# Please note that all operations are done on em1 interface. This is due em0
# interface is used only to have internet access inside the VM
ifconfig em1 inet 10.18.1.2/24

# network between routers R2(IF2) and R1(IF1)
ifconfig vlan5 create
ifconfig vlan5 inet 10.18.51.66/26 vlan 5 vlandev em1
# network between routers R2(IF1) and R3(IF2)
ifconfig vlan6 create
ifconfig vlan6 inet 10.18.51.129/26 vlan 6 vlandev em1
# subnet with data R2(IF3)
ifconfig vlan203 create
ifconfig vlan203 inet 192.168.6.3/24 vlan 203 em1

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
hostname shanee.anxolerd.net
password zebra

debug rip events
debug rip packet

router rip
version 2
redistribute connected

network vlan5
network vlan6
network vlan203

log file /var/log/quagga/ripd.log
log stdout
EOF

cat >/usr/local/etc/quagga/zebra.conf <<EOF
hostname shanee.anxolerd.net
password zebra
enable password zebra

interface vlan5
  multicast

interface vlan6
  multicast

interface vlan203
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
hostname="shanee"

ifconfig_em1="inet 10.0.1.2 netmask 255.255.255.0"
cloned_interfaces="vlan5 vlan6 vlan203"
ifconfig_vlan5="inet 10.18.51.66/26 vlan 5 vlandev em1"
ifconfig_vlan6="inet 10.18.51.129/26 vlan 6 vlandev em1"
ifconfig_vlan203="inet 192.168.6.3/24 vlan 203 vlandev em1"

quagga_enable="YES"
quagga_daemons="zebra ripd"
EOF
