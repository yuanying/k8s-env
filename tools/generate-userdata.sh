#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_OS_DISTRO=${1:-'ubuntu'}
export NODE_HOSTNAME=${2:-'master'}
export NODE_ADDRESS=${3:-'192.168.203.11'}

export NODE_NETWORK_RANGE=${NODE_NETWORK_RANGE:-'24'}
export NODE_PUBLIC_KEY=${NODE_PUBLIC_KEY:-'auto'}

function cdr2mask {
    # Number of args to shift, 255..255, first non-255 byte, zeroes
    set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
    [ $1 -gt 1 ] && shift $1 || shift
    echo ${1-0}.${2-0}.${3-0}.${4-0}
}

_NODE_NETMASK=$(cdr2mask ${NODE_NETWORK_RANGE})
export NODE_NETMASK=${NODE_NETMASK:-${_NODE_NETMASK}}

if [[ ${NODE_PUBLIC_KEY} == "auto" ]]; then
    export NODE_PUBLIC_KEY=`cat ~/.ssh/id_rsa.pub`
fi

script_dir=`dirname $0`
bash $script_dir/templates/cloud-config-${NODE_OS_DISTRO}.yaml
