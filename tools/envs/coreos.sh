#!/usr/bin/env bash

env_dir=$(dirname "${BASH_SOURCE}")
source ${env_dir}/common.sh

CHANNEL=stable
RELEASE=current
export NODE_OS_DISTRO='coreos'
export NODE_IMAGE_ORG="/var/lib/libvirt/images/coreos_${CHANNEL}_${RELEASE}_qemu_image.img"
export NODE_IMAGE="/var/lib/libvirt/images/coreos_${CHANNEL}_${RELEASE}_qemu_image.qcow2"
export NODE_ADDRESS_PREFIX=${NODE_ADDRESS_PREFIX:-'192.168.1'}
export NODE_NET_DEVICE='eth0'

export NODE_ADDITIONAL_DISKS=''


if [ ! -f ${NODE_IMAGE_ORG} ]; then
    sudo bash -c "wget https://${CHANNEL}.release.core-os.net/amd64-usr/${RELEASE}/coreos_production_qemu_image.img.bz2 -O - | bzcat > ${NODE_IMAGE_ORG} || (rm -f ${NODE_IMAGE_ORG} && echo 'Failed to download image' && exit 1)"
fi
if [ ! -f ${NODE_IMAGE} ]; then
    sudo qemu-img create -f qcow2 -b ${NODE_IMAGE_ORG} ${NODE_IMAGE}
fi
