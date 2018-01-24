#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

source ${ROOT}/../configs/bin/glusterfs.sh

for NODE in ${GLUSTER_NODE}; do
  kubectl get pod -n storage --selector glusterfs-node=pod -o json | \
      jq ".items[0].metadata.name" -r | \
      xargs -I{} kubectl exec -t {} gluster peer probe ${NODE}
done
