#!/usr/bin/env bash

script_dir=$(dirname "${BASH_SOURCE}")

export NODE_OS_DISTRO='centos'
export NODE_IMAGE='/var/lib/libvirt/images/centos7-docker-ec2-noclouds.qcow2'
export NODE_HOSTNAME='centos-master01'
export NODE_ADDRESS='192.168.202.11'
export NODE_GATEWAY='192.168.11.1'
export NODE_DNS='192.168.11.1'
export NODE_NETWORK_RANGE='16'
export NODE_NET_DEVICE='ens3'

export NODE_ADDITIONAL_DISKS=''
export NODE_USERDATA=${script_dir}/../userdata/centos-master01.yaml
