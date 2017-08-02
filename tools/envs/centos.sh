#!/usr/bin/env bash

env_dir=$(dirname "${BASH_SOURCE}")
source ${env_dir}/common.sh

export NODE_OS_DISTRO='centos'
export NODE_IMAGE='/var/lib/libvirt/images/centos7-docker-ec2-noclouds.qcow2'
export NODE_ADDRESS_PREFIX=${NODE_ADDRESS_PREFIX:-'192.168.202'}
export NODE_NET_DEVICE='ens3'

export NODE_ADDITIONAL_DISKS=''
