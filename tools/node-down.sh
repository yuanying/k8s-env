#!/usr/bin/env bash

export LC_ALL=C

NODE_ENV=${1:-""}
script_dir=$(dirname "${BASH_SOURCE}")

if [[ ${NODE_ENV} != '' ]]; then
    source ${NODE_ENV}
fi

LIBVIRT_PATH=${LIBVIRT_PATH:-'/var/lib/libvirt/images'}

sudo virsh destroy ${NODE_HOSTNAME}
sudo virsh undefine ${NODE_HOSTNAME}
sudo sh -c "rm -rf ${LIBVIRT_PATH}/${NODE_HOSTNAME}*"
