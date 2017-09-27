# FreeBSD version 11.1
# Image: bootonly
# Use LiveCD, username: root

# 1. Partition hard drive
# =======================
gpart destroy ada0
gpart create -s mbr ada0

# slice
gpart add -t freebsd -s 4096M ada0
gpart create -s bsd ada0s1

# partitions
# /
gpart add -t freebsd-ufs -s 350M ada0s1
glabel label root ada0s1a
# swap
gpart add -t freebsd-ufs -s 256M ada0s1
glabel label swap ada0s1b
# /var
gpart add -t freebsd-ufs -s 500M ada0s1
glabel label var ada0s1d
# /tmp
gpart add -t freebsd-ufs -s 350M ada0s1
glabel label tmp ada0s1e
# /usr
gpart add -t freebsd-ufs -s 2640M ada0s1
glabel label usr ada0s1a

# create filesystems
newfs -U -L root /dev/label/root
newfs -U -L var /dev/label/var
newfs -U -L tmp /dev/label/tmp
newfs -U -L usr /dev/label/usr

# mount
mount -o rw /dev/label/root /mnt
mkdir -p /mnt/var
mount -o rw /dev/label/var /mnt/var
mkdir -p /mnt/tmp
mount -o rw /dev/label/tmp /mnt/tmp
mkdir -p /mnt/usr
mount -o rw /dev/label/usr /mnt/usr

gpart bootcode -b /boot/mbr ada0
gpart set -a active -i 1 ada0
gpart bootcode -b /boot/boot ada0s1

# 2. Download and install base system
# ===================================
cd /mnt
dhclient em0
fetch ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/11.1-RELEASE/base.txz
fetch ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/11.1-RELEASE/kernel.txz

tar xjpf base.txz
tar xjpf kernel.txz

# 3. Fstab
# ========

cat >/mnt/etc/fstab <<EOF
# Device        Mountpoint      FStype  Options Dump    Pass
/dev/label/root /               ufs     rw      1       1
/dev/label/swap none            swap    sw      0       0
/dev/label/var  /var            ufs     rw      1       2
/dev/label/tmp  /tmp            ufs     rw      1       2
/dev/label/usr  /usr            ufs     rw      1       2
EOF

# 4. Startup
# ==========

sed -i.bak 's/#PermitRootLogin no/PermitRootLogin yes/g' /mnt/etc/ssh/sshd_config
echo '#!/bin/sh' > /mnt/etc/rc.conf
echo 'ifconfg_em0="DHCP"' >> /mnt/etc/rc.conf
echo 'sshd_enable="YES"' >> /mnt/etc/rc.conf
echo 'hostname="monica"' >> /mnt/etc/rc.conf

# 5. Chroot and root password
# ===========================

cd /mnt
chroot .
passwd
exit

# 6. Reboot
# =========
reboot

# 7. Cleanup
# ==========
rm /base.txz
rm /kernel.txz
