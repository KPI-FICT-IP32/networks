#!/bin/sh
set -x

dnf install -y telnet openssl

if grep -q '#lab' /etc/hosts; then
    echo "ips already configured"
else
    echo "172.25.11.5    mail.zone05.net" >> /etc/hosts
    echo "172.25.11.10   noauth.zone05.net" >> /etc/hosts
    echo "172.25.11.42   auth.zone05.net" >> /etc/hosts
fi
