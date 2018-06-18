#!/bin/sh

dnf install -y \
    postfix \
    dovecot


for user in 'alpha' 'beta' 'gamma' 'delta' 'omega'; do
    useradd -s /sbin/nologin "${user}"
done



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
#mynetworks = 168.100.189.0/28, 127.0.0.0/8
#mynetworks = $config_directory/mynetworks

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
# TODO: Not working
# smtpd_sasl_type = dovecot
# smtpd_sasl_auth_enable = yes
# broken_sasl_auth_clients = yes
# smtpd_sasl_security_oprions = noanonymous
# smtpd_sasl_paht = private/auth
# 
# smtpd_relay_restrictions =
#     permit_mynetworks
#     permit_sasl_authenticated
#     reject_unauth_destination
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


systemctl restart postfix
systemctl enable postfix
