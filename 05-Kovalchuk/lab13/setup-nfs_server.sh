#!/bin/sh
set -ex

# install nfs-utils, which provide nfs server functionality
apk add nfs-utils

# create shared directories
mkdir -p /usr/public
mkdir -p /usr/share

# configure exported directories
cat > /etc/exports << 'EOF'
/usr/public 10.18.51.0/24(ro,subtree_check)
/usr/share  10.18.51.6(rw,subtree_check,no_root_squash)
EOF

# run nfs server at boot
rc-update add nfs
# start nfs server
rc-service nfs start
