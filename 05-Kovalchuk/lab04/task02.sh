#!/bin/sh

# In order to generate incoming traffic
# a host-only network 10.18.51.0/24 was configured in virtualbox

set -ex

# Traffic generation functions
generate_outgoing_icmp()
{
  for i in `seq 4`; do
    ping -W 1 -c 4 "10.18.48.$i" >/dev/null || true
    sleep .5
  done
}

generate_outgoing_icmp &

# Dump traffic:
# INCOMING: TCP syn, UDP from network 10.18.51.0/24
# OUTGOING: ICMP to 10.18.48.0/24

src_net='10.18.51.0/24'
dst_net='10.18.48.0/24'
incoming_filter="((tcp[tcpflags] & tcp-syn != 0) or udp) and src net ${src_net}"
outgoing_filter="icmp and dst net ${dst_net}"
for interface in `ifconfig -l`; do
  tcpdump -i "$interface" "(${incoming_filter}) or (${outgoing_filter})" &
done


