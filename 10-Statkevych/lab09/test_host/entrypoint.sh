#!/bin/bash

echo "nameserver 10.18.51.2" > /etc/resolv.conf
echo "nameserver 10.18.51.11" > /etc/resolv.conf
echo "options ndots:0" >> /etc/resolv.conf

/bin/bash