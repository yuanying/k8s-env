#!/usr/bin/env bash

env_dir=$(dirname "${BASH_SOURCE}")

source ${env_dir}/${NODE_OS_DISTRO}.sh

export NODE_HOSTNAME="${NODE_OS_DISTRO}-worker05"
export NODE_ADDRESS="${NODE_ADDRESS_PREFIX}.125"

export NODE_ADDITIONAL_DISKS='10 10'
export NODE_USERDATA=${env_dir}/../userdata/${NODE_OS_DISTRO}-worker05.yaml
