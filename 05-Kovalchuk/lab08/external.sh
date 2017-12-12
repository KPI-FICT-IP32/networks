#!/bin/sh

# ====================
# Configure ip address
# ====================
cat << 'EOF' >/etc/rc.conf
#!/bin/sh
ifconfig_em0="inet 10.18.51.10/24"
hostname="jill"
EOF
