#!/bin/sh

# ==============
# Firewall rules
# ==============
cat << 'EOF' >/etc/ipfw.rules
# Drop all existing rules
ipfw -q flush

cmd="ipfw -q add"
ks="keep-state"

# Allow loopback
$cmd 65533 allow all from any to any via lo0
$cmd 65534 check-state

# Allow FTP to 10.18.49.0/24.
ftp_net="10.18.49.0/24"
$cmd 00100 allow tcp from me to $ftp_net 20 out setup $ks
$cmd 00101 allow udp from me to $ftp_net 20 out $ks
$cmd 00102 allow tcp from me to $ftp_net 21 out setup $ks
$cmd 00103 allow udp from me to $ftp_net 21 out $ks

# Allow POP3 to any network
$cmd 00104 allow tcp from me to any 106 out setup $ks
$cmd 00105 allow tcp from me to any 110 out setup $ks
$cmd 00106 allow udp from me to any 110 out $ks

# Allow SMTP to server
$cmd 00107 allow tcp from any to me 25 in setup $ks
$cmd 00108 allow udp from any to me 25 in $ks

# Allow IP from/to 10.18.48.0/24
ip_net="10.18.48.0/24"
$cmd 00109 allow ip from $ip_net to me in $ks
$cmd 00110 allow ip from any to $ip_net out $ks

# count incoming TCP
$cmd 00111 count tcp from any to me in

# log incomminf traffic from 10.18.51.0/24
logged_net="10.18.51.0/24"
$cmd 00112 allow log any from $logged_net to any
EOF

# =====================
# Startup configuration
# =====================
cat >/etc/rc.conf <<EOF
ifconfig_em0="DHCP"

ifconfig_em1="inet 10.18.51.100 netmask 255.255.255.0"
dhcpd_enable="YES"

sshd_enable="YES"
hostname="monica"

# firewall_enable="YES"
firewall_script="/etc/ipfw.rules"
firewall_quiet="YES"
firewal_logging="YES"
EOF

mkdir -p /var/log/ipfw
touch /var/log/ipfw/ipfw.log
chmod -R go-rwx /var/log/ipfw

# =======================
# Reboot and run firewall
# =======================

reboot
service ipfw onestart
