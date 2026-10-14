#!/usr/bin/env bash
set -eu
export LC_ALL=C

cat <<EOS
version: 2
ethernets:
  ${NODE_NET_DEVICE}:
    dhcp4: false
    accept-ra: true
    addresses:
    - ${NODE_ADDRESS}/${NODE_NETWORK_RANGE}
    routes:
    - to: default
      via: ${NODE_GATEWAY}
    nameservers:
      addresses:
      - ${NODE_DNS}
EOS
