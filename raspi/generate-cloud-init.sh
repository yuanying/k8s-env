#!/usr/bin/env bash
# Raspberry Pi の system-boot パーティションに置く cloud-init の
# user-data / network-config を生成する。
#   bash raspi/generate-cloud-init.sh raspi/envs/rasp01.sh <出力先ディレクトリ>

set -eu
export LC_ALL=C

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <node env> <output dir>" >&2
    exit 1
fi

NODE_ENV=$1
OUTPUT_DIR=$2
script_dir=$(dirname "${BASH_SOURCE}")

source ${NODE_ENV}

: ${NODE_HOSTNAME:?'NODE_HOSTNAME is required'}
: ${NODE_ADDRESS:?'NODE_ADDRESS is required'}

tmp_dir=$(mktemp -d)
trap 'rm -rf ${tmp_dir}' EXIT

bash ${script_dir}/templates/user-data.sh > ${tmp_dir}/user-data
bash ${script_dir}/templates/network-config.sh > ${tmp_dir}/network-config

mkdir -p ${OUTPUT_DIR}
cp ${tmp_dir}/user-data ${tmp_dir}/network-config ${OUTPUT_DIR}/
echo "Generated: ${OUTPUT_DIR}/user-data ${OUTPUT_DIR}/network-config"
