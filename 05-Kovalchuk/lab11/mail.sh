#!/bin/sh

dnf install -y \
    dovecot \


# Create users
for user in 'tiger' 'lion' 'lynx' 'leopard' 'jaguar'; do
    useradd -s /sbin/nologin "${user}"
done

# set users with plain login
for user in 'leopard' 'jaguar'; do
    chpasswd <<< "${user}:${user}"  # password the same as username
done

# set users with cram-md5
touch /etc/cram-md5
chmod 0600 /etc/cram-md5
for user in 'tiger' 'lion' 'lynx'; do
	pwdhash=$(echo -e "${user}\n${user}\n" | doveadm pw | cut -c 11-)
	echo "${user}:${pwdhash}" >> /etc/cram-md5
done
chown dovecot:dovecot /etc/cram-md5

if [ ! -e /etc/dovecot/dovecot.conf.bak ]; then
    mv /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.bak
fi

cat >/etc/dovecot/dovecot.conf << 'EOF'
auth_mechanisms = plain login cram-md5
disable_plaintext_auth = no
mail_location = maildir:~/Maildir
mbox_write_locks = fcntl

# Where to find users
userdb pam { 
  driver = passwd
}

# How to verify passwords
passdb pam {
  driver = pam
}
passdb cram { 
  driver = passwd-file
  # Path for passwd-file. Also set the default password scheme.
  args = scheme=cram-md5 /etc/cram-md5
}

# SSL
ssl = required
ssl_cert = </etc/pki/dovecot/certs/dovecot.pem
ssl_key = </etc/pki/dovecot/private/dovecot.pem
EOF

systemctl restart dovecot
systemctl enable dovecot
