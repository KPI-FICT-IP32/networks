#!/bin/sh
set -ex

apk add nfs-utils

rc-update add nfsmount
rc-service nfsmount start
