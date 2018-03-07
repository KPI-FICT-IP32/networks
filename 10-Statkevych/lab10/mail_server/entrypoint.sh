#!/bin/bash

rsyslogd
cd /etc/mail/

make

# add dns servers list
echo "nameserver 10.18.51.2" > /etc/resolv.conf
echo "nameserver 10.18.51.11" >> /etc/resolv.conf
echo "options ndots:0" >> /etc/resolv.conf

echo "127.0.0.1 localhost" > /etc/hosts

# Add relays for particular subnetworks and allow emailing from certain hosts
echo "172.21.11	RELAY" >> /etc/mail/access
echo "root@venus	OK" >> /etc/mail/access
echo "root@mercury	OK" >> /etc/mail/access

makemap hash /etc/mail/access < /etc/mail/access

echo "smtp.zone10.org.ua" >> /etc/mail/local-host-names

# adding users for creating 2 mailboxes (venus@smtp.zone10.org.ua, mercury@smtp.zone10.org.ua)
useradd venus
useradd mercury

# That's may be redundant
echo "root@venus	venus" > hash /etc/mail/virtusertable
echo "root@mercury	mercury" >> hash /etc/mail/virtusertable

makemap hash /etc/mail/virtusertable < /etc/mail/virtusertable

/etc/init.d/sendmail start

tail -f /var/log/syslog
