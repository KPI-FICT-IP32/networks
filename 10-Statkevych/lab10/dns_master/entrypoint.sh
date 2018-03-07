#!/bin/bash

touch /var/log/bind.log

chown bind:bind /var/log/bind.log

/etc/init.d/bind9 start

tail -f /var/log/bind.log