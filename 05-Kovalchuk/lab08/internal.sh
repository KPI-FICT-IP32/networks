#!/bin/sh

# ========================================
# Configure ip address and default gateway
# ========================================
cat << 'EOF' >/etc/rc.conf
#!/bin/sh
ifconfig_em0="inet 192.168.1.10/24"
defaultrouter="192.168.1.1"
hostname="john"
EOF
