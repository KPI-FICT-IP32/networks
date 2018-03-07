#!/bin/bash

touch /var/log/bind.log

chown bind:bind /var/log/bind.log

mkdir /etc/bind/zones

touch /etc/bind/zones/zone10.org.ua

chmod 777 /etc/bind/zones/

chown bind:bind /etc/bind/zones/
chown bind:bind /etc/bind/zones/*

/etc/init.d/bind9 start

tail -f /var/log/bind.log