#!/bin/sh

# =============================
# Configure Address Translation
# =============================
echo << 'EOF' >/etc/firewall
#!/bin/sh
ipfw -q flush

# First we just passthrough packets to 25th port as is
ipfw -q add 00100 allow all from 192.168.1.10 to 10.18.51.0/24 25

# For other packets from 192.168.1.10 to 10.18.51.0 do address translation
ipfw -q add 00200 divert natd all from 192.168.1.10 to 10.18.51.0/24 via em1
ipfw -q add 00300 divert natd all from any to me via em1
EOF

# =========================
# Configure Port Forwarding
# =========================
echo << 'EOF' >/etc/natd.conf
redirect_port tcp 192.168.1.10:143 143
redirect_port tcp 192.168.1.10:110 110
EOF


# =============================
# Run all the things at startup
# =============================
echo << 'EOF' >/etc/rc.conf
#!/bin/sh
# internal network
ifconfig_em0="inet 192.168.1.1/24"
# external IP address
ifconfig_em1="inet 10.18.51.1/24"
hostname="olya"
sshd_enable="YES"

firewall_enable="YES"
firewall_nat_enable="YES"
firewall_gateway="YES"
gateway_enable="YES"
dummynet_enable="YES"
firewall_script="/etc/firewall"

natd_enable="YES"
natd_interface="em1"
natd_flags="-f /etc/natd.conf"
EOF

# ===============
# Troubleshouting
# ===============
# If the configuration above does not work
# You probably need to enable NAT support in Kernel
# as well as ensure your firewall allows all packets by default
# To do so, build the kernel with following options:
#
# options     IPFIREWALL
# options     IPFIREWALL_DEFAULT_TO_ACCEPT
# options     IPFIREWALL_VERBOSE
# options     IPFIREWALL_VERBOSE_LIMIT=100
# options     IPDIVERT
# options     DUMMYNET
#
# Modified kernel configuration from lab03 can be found in
# kernel05 file in this directory
