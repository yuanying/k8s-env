#!/usr/bin/env bash

env_dir=$(dirname "${BASH_SOURCE}")
source ${env_dir}/common.sh

export NODE_OS_DISTRO='ubuntu'
export NODE_OS_CODENAME='bionic'
export NODE_OS_URL="http://cloud-images.ubuntu.com/${NODE_OS_CODENAME}/current/${NODE_OS_CODENAME}-server-cloudimg-amd64.img"
export NODE_IMAGE_ORG=${NODE_IMAGE_ORG:-"${NODE_ROOT}/${NODE_OS_CODENAME}-server-cloudimg-amd64.img"}
export NODE_IMAGE=${NODE_IMAGE:-"${NODE_ROOT}/${NODE_OS_CODENAME}-server-cloudimg-amd64.qcow2"}
export NODE_ADDRESS_PREFIX=${NODE_ADDRESS_PREFIX:-'192.168.201'}
export NODE_NET_DEVICE='ens3'

export NODE_ADDITIONAL_DISKS=''

if [ ! -f ${NODE_IMAGE_ORG} ]; then
        sudo bash -c "wget ${NODE_OS_URL} -O - > ${NODE_IMAGE_ORG} || (rm -f ${NODE_IMAGE_ORG} && echo 'Failed to download image' && exit 1)"
fi
if [ ! -f ${NODE_IMAGE} ]; then
        sudo qemu-img create -f qcow2 -b ${NODE_IMAGE_ORG} ${NODE_IMAGE}
fi
