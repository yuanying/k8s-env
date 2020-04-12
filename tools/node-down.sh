#!/usr/bin/env bash

export LC_ALL=C

NODE_ENV=${1:-""}
script_dir=$(dirname "${BASH_SOURCE}")

if [[ ${NODE_ENV} != '' ]]; then
    source ${NODE_ENV}
fi

NODE_ROOT=${NODE_ROOT:-'/var/vms'}

sudo virsh destroy ${NODE_HOSTNAME}
sudo virsh undefine ${NODE_HOSTNAME}
sudo sh -c "rm -rf ${NODE_ROOT}/${NODE_HOSTNAME}*"
