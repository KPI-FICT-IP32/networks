#!/bin/sh
set -x

# install required packages
dnf install -y samba samba-common perl

# configure firewall
firewall-cmd --permanent --zone=public --add-service=samba
firewall-cmd --reload

# create directories
mkdir -p /srv/samba/{hidden,pub,incoming}

# add group and users
groupadd smbgrp
for user in 'lynx' 'leopard'; do
    useradd \
        --shell=/sbin/nologin \
        --comment="Samba user ${user}" \
        "${user}"
    echo "${user}:${user}" | chpasswd
    gpasswd -a "${user}" smbgrp
    echo -ne "${user}\n${user}\n" | smbpasswd -a "${user}"
    smbpasswd -e "${user}"
done

# set proper permissions to directories
chown -R :smbgrp /srv/samba/hidden
chown -R :smbgrp /srv/samba/pub
chown -R :smbgrp /srv/samba/incoming
chmod 0775 /srv/samba/hidden
chmod 0777 /srv/samba/incoming

# selinux configuration
/usr/sbin/setsebool -P samba_enable_home_dirs on
chcon -t samba_share_t /srv/samba/hidden
chcon -t samba_share_t /srv/samba/pub
chcon -t samba_share_t /srv/samba/incoming

# Write samba configuration file
cat > /etc/samba/smb.conf << 'EOF'
[global]
map to guest = Bad User
netbios name = sambasrv
security = user
workgroup = WORKGROUP

[hidden]
Comment = Hidden File Server Share
browseable = no
create mask = 0755
guest ok = no
path = /srv/samba/hidden
read list = lynx leopard
read only = no
write list = lynx
writable = yes

[homes]
Comment = Users' Home Directories
browseable = yes
writable = yes
valid users = %S

[pub]
Comment = Readonly Public Directory
browseable = yes
guest ok = yes
path = /srv/samba/pub/
read only = yes
valid users = lynx nobody
writable = no

[incoming]
Comment = Public Directory
browseable = yes
guest ok = yes
path = /srv/samba/incoming/
read only = no
writable = yes
force create mode = 0666
force directory mode = 2777
force user = nobody
EOF

# run samba service
for service in 'smb' 'nmb'; do
    systemctl enable "${service}"
    systemctl start "${service}"
done
