#!/bin/sh
set -e

# All manipulations are done with em0 interface

# 1. Add additional IP address 
# ============================
ifconfig em0 add 192.168.5.1

# 2. Change MAC address and working mode
# ======================================
ifconfig em0 lladdr 00:11:11:11:22:22
ifconfig em0 media 100baseTX
ifconfig em0 mediaopt full-duplex

# 3. Change MTU
# =============
ifconfig em0 mtu 300

# 4. Ping 10.18.49.10 with 5 packets and mtu 600
# ==============================================
ping -c 5 -s 600 10.18.49.10

# 5. Using ping and traceroute show the path to 10.18.50.1
# ========================================================

# Buggy function which emulates traceroute via ping command
pingroute()
{
  dest="$1"
  msg="(Destination (host|net) unreachable|Time to live exceeded)"
  for ttl in `seq 15`; do
    set +e
    ping_stats="$(ping -vvv -no -c 1 -m ${ttl} "${dest}")"
    is_fin=$?
    set -e
    if [ $is_fin -eq 0 ] ; then
        echo "${ttl}    ${dest}"
        echo "DONE"
        break
    fi

    error_msg="$(echo "${ping_stats}" | egrep -i "${msg}")" || true
    case "$error_msg" in
      *"Time to live exceeded")
        addr=$(echo "${error_msg}" | awk '{print $4}' | sed -e 's/://g')
        echo "${ttl}    ${addr}"
        ;;
      *)
        echo "${ttl}    *    ${error_msg}"
        ;;
    esac
  done
}

# Traceroute using ping
pingroute 10.18.50.1


# Normal traceroute
traceroute 10.18.50.1
traceroute -I 10.18.50.1

# 6. Print statistics of TCP,UDP,ICMP,IP protocols
# ================================================

netstat -ni -p tcp -p udp -p icmp -p ip -h

# 7. Find IP address by name
# ==========================

# nslookup and dig utilities are not included in base system anymore
# however there are replacements: host and drill

host samba.org
drill samba.org
