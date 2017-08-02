#!/usr/bin/env bash

env_dir=$(dirname "${BASH_SOURCE}")
source ${env_dir}/common.sh

export NODE_OS_DISTRO='ubuntu'
export NODE_IMAGE="/var/lib/libvirt/images/ubuntu-xenial-docker-ec2-noclouds.qcow2"
export NODE_ADDRESS_PREFIX=${NODE_ADDRESS_PREFIX:-'192.168.201'}
export NODE_NET_DEVICE='ens3'

export NODE_ADDITIONAL_DISKS=''
