#!/usr/bin/env bash
# 本番投入前の単体検証機。ホスト名と仮の空きアドレスは呼び出し時に渡す。
#   NODE_HOSTNAME=rasp-verify NODE_ADDRESS=192.168.1.x bash raspi/generate-cloud-init.sh raspi/envs/verify.sh <出力先>

env_dir=$(dirname "${BASH_SOURCE}")
source ${env_dir}/common.sh

export NODE_HOSTNAME=${NODE_HOSTNAME:-'rasp-verify'}
export NODE_ADDRESS=${NODE_ADDRESS:?'NODE_ADDRESS (仮の空きアドレス) を指定してください'}
