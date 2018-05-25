#!/bin/sh
set -ex

# Install vsftpd
apk add vsftpd

mkdir -p /var/ftp/
chown nobody:nogroup /var/ftp/

# Anonymous user access
mkdir -p /var/ftp/anonymous
mkdir -p /var/ftp/anonymous/pub
mkdir -p /var/ftp/anonymous/incoming
chown -R nobody:nogroup /var/ftp/anonymous
chmod 755 /var/ftp/anonymous
chmod 755 /var/ftp/anonymous/pub
chown -R ftp /var/ftp/anonymous/incoming
chmod 755 /var/ftp/anonymous/incoming

# Regular users
for user in 'tiger' 'lion' 'lynx' 'leopard' 'jaguar' ; do
    adduser -h "/var/ftp/${user}" -s nologin -G ftp -D "${user}"
    echo "${user}:${user}" | chpasswd
    chown -R "${user}:ftp" "/var/ftp/${user}"
    chmod 775 "/var/ftp/${user}"
done

# vst
cat >/etc/vsftpd.conf << 'EOF'
# Show the user and group as ftp:ftp regardless of the owner
hide_ids=YES

# Fix for 500 error. TODO: investigate
seccomp_sandbox=NO

# Mode for opening files
file_open_mode=0666

# Logging
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log
log_ftp_protocol=YES

# anonymous user configuration
anonymous_enable=YES
anon_root=/var/ftp/anonymous
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
no_anon_password=YES
anon_umask=0002
chown_upload_mode=0666

# general users
local_enable=YES
local_root=/var/ftp
write_enable=YES
local_umask=0002
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES

user_config_dir=/etc/vsftpd.user_conf.d

listen=YES
EOF

mkdir -p /etc/vsftpd.user_conf.d
for user in 'tiger' 'jaguar' ; do
    echo "local_root=/var/ftp/${user}" > "/etc/vsftpd.user_conf.d/${user}"
done
