#!/bin/sh

dnf install -y \
    postfix \
    dovecot \
    policycoreutils-python-utils


for user in 'alpha' 'beta' 'gamma' 'delta' 'omega'; do
    useradd -s /sbin/nologin "${user}"
    chpasswd <<< "${user}:${user}"  # password the same as username
done


if [ ! -e /etc/dovecot/dovecot.conf.bak ]; then
    mv /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.bak
fi

cat >/etc/dovecot/dovecot.conf << 'EOF'
auth_mechanisms = plain login
disable_plaintext_auth = no
mail_location = maildir:~/Maildir
mbox_write_locks = fcntl

# The following is for integration with postfix
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
    user = postfix
    group = postfix
  }
}

# Where to find users
userdb { 
  driver = passwd
}

# How to verify passwords
passdb {
  driver = pam
}

# SSL
ssl = required
ssl_cert = </etc/pki/dovecot/certs/dovecot.pem
ssl_key = </etc/pki/dovecot/private/dovecot.pem
EOF

systemctl restart dovecot
systemctl enable dovecot


cat >/etc/postfix/main.cf << 'EOF'
# INTERNET HOST AND DOMAIN NAMES
myhostname = mail.zone05.net
mydomain = zone05.net


# SENDING MAIL
# The myorigin parameter specifies the domain that locally-posted
# mail appears to come from.
myorigin = $mydomain

# RECEIVING MAIL
inet_interfaces = all
inet_protocols = all

# The mydestination parameter specifies the list of domains that this
# machine considers itself the final destination for.
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain

unknown_local_recipient_reject_code = 550

# TRUST AND RELAY CONTROL
mynetworks =
    172.25.11.10
    172.25.11.20
    172.25.11.30
    172.25.11.40
    172.25.11.50
    127.0.0.0/8

# ALIAS DATABASE
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases

# ADDRESS EXTENSIONS (e.g., user+foo)
recipient_delimiter = +

# DELIVERY TO MAILBOX
home_mailbox = Maildir/

# SHOW SOFTWARE VERSION
smtpd_banner = $myhostname ESMTP $mail_name ($mail_version)

# AUTH
smtpd_sasl_type = dovecot
smtpd_sasl_auth_enable = yes
broken_sasl_auth_clients = yes
smtpd_sasl_security_options = noanonymous
smtpd_sasl_path = private/auth

smtpd_client_restrictions =
    permit_mynetworks
    permit_sasl_authenticated
    reject

# TLS
smtpd_tls_cert_file = /etc/pki/dovecot/certs/dovecot.pem
smtpd_tls_key_file = /etc/pki/dovecot/private/dovecot.pem
smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_cache
smtpd_tls_security_level = may
smtp_tls_security_level = may
EOF


cat >/etc/aliases << 'EOF'
# Basic system aliases -- these MUST be present.
mailer-daemon:  postmaster
postmaster:     root

# trap decode to catch security attacks
decode:         root

# Cusrom aliases
srv01:          alpha
srv02:          beta
srv03:          gamma
srv04:          delta
srv05:          omega
EOF

newaliases

# The following is SELinux permission for postfix to read dovecot certs
cat >/root/my-smtpd.te << 'EOF'
module my-smtpd 1.0;

require {
        type dovecot_cert_t;
        type postfix_smtpd_t;
        class dir search;
        class file { getattr open read };
}

#============= postfix_smtpd_t ==============
allow postfix_smtpd_t dovecot_cert_t:dir search;
allow postfix_smtpd_t dovecot_cert_t:file { getattr open read };
EOF
semodule -r my-smtpd
rm -f /root/my-smtpd.mod /root/my-smtpd.pp
checkmodule -M -m -o /root/my-smtpd.mod /root/my-smtpd.te
semodule_package -o /root/my-smtpd.pp -m /root/my-smtpd.mod
semodule -i /root/my-smtpd.pp


systemctl restart postfix
systemctl enable postfix
