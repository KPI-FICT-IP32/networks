#!/bin/bash
env

echo "nameserver 10.18.51.2" > /etc/resolv.conf
echo "nameserver 10.18.51.11" >> /etc/resolv.conf
echo "options ndots:0" >> /etc/resolv.conf

# not sure if it is ok
echo "127.0.0.1 "$HOSTNAME".zone10.org.ua" > /etc/hosts
rsyslogd

mkdir /etc/mail/auth
chmod 700 /etc/mail/auth
# This may be redundant
echo 'AuthInfo:smtp.zone10.org.ua: "U:'${HOSTNAME}'"' > /etc/mail/auth/smtp-auth
cd /etc/mail/auth
makemap hash smtp-auth < smtp-auth
chmod 600 smtp-auth smtp-auth.db

/etc/init.d/sendmail start

tail -f /var/log/syslog
