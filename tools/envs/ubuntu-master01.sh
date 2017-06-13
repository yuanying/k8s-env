#!/usr/bin/env bash

script_dir=$(dirname "${BASH_SOURCE}")

export NODE_HOSTNAME='master01'
export NODE_ADDRESS='192.168.203.11'
export NODE_GATEWAY='192.168.11.1'
export NODE_DNS='192.168.11.1'
export NODE_NETWORK_RANGE='16'
export NODE_NET_DEVICE='ens3'

export NODE_ADDITIONAL_DISKS=''
export NODE_USERDATA=${script_dir}/../userdata/ubuntu-master01.yaml
