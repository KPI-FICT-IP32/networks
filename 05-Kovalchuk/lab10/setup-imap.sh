#!/bin/sh


# Install dovecot
dnf install -y dovecot

# Create virtual mail user
useradd vmail --shell /sbin/nologin

cat >/etc/dovecot/dovecot.conf << 'EOF'
auth_mechanisms = plain login

mail_gid = vmail
mail_uid = vmail

# users mail boxes
mail_home = /home/vmail/%d/%n
mail_location = maildir:~/Maildir

mbox_write_locks = fcntl

# the following directive defines where dovecot will be looking for usernames
userdb {
    args = username_format=%u /etc/dovecot/users
    driver = passwd-file
}

# the following directive defines where dovecot will be looking for passwords
passdb {
    args = scheme=ssha512 username_format=%u /etc/dovecot/users
    driver = passwd-file
}

# services for postfix integration
service auth {
    unix_listener /var/spool/postfix/private/auth {
        group = postfix
        mode = 0660
        user = postfix
    }

    unix_listener auth-userdb {
        mode = 0660
        user = vmail
    }
}

service lmtp {
    unix_listener /var/spool/postfix/private/dovecot-lmtp {
        group = postfix
        mode = 0600
        user = postfix
    }
    user = vmail
}

protocol lmtp {
    postmaster_address = root@zone05.net
}

# ssl
ssl_cert = </etc/pki/dovecot/certs/dovecot.pem
ssl_key = </etc/pki/dovecot/private/dovecot.pem
EOF

touch /etc/dovecot/users
for user in 'tiger' 'lion' 'lynx' 'leopard' 'jaguar'; do
    password=$(doveadm pw -s ssha512 -p ${user})
    echo "${user}:${password}::::::" >> /etc/dovecot/users
done
