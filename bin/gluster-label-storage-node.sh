#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

source ${ROOT}/../configs/bin/glusterfs.sh

for NODE in ${GLUSTER_NODE}; do
  kubectl label node ${NODE} storagenode=glusterfs
done
