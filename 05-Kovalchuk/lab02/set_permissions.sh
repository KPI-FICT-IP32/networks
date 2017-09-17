#!/bin/sh

# 1. Create groups city1 and city2
# ================================
pw groupadd city1
pw groupadd city2

# 2. Create users and add them to groups
# ======================================
pw useradd -n london -c 'London, UK' -m -s /bin/sh -g city1 -G city2
pw useradd -n paris -c 'Paris, France' -m -s /bin/sh -g city1
pw useradd -n rome -c 'Rome, Italy' -m -s /bin/sh -g city1
pw useradd -n berlin -c 'Berlin, Germany' -m -s /bin/sh -g city1

# 3. Create directories and set permissions
# =========================================
mkdir -p /dir09
chmod 540 /dir09
chown paris:city1 /dir09

mkdir -p /dir10
chmod 054 /dir10
chown rome:city2 /dir10
