#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

source ${ROOT}/../configs/bin/nginx-ingress.sh

for NODE in ${INGRESS_NODE}; do
  kubectl label node ${NODE} ingressnode=nginx
done
