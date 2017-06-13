#!/usr/bin/env bash

export LC_ALL=C

NODE_HOSTNAME=${NODE_HOSTNAME:-$1}
LIBVIRT_PATH=${LIBVIRT_PATH:-'/var/lib/libvirt/images'}

sudo virsh destroy ${NODE_HOSTNAME}
sudo virsh undefine ${NODE_HOSTNAME}
sudo rm -rf ${LIBVIRT_PATH}/${NODE_HOSTNAME}*
