#!/usr/bin/env bash

set -eu
export LC_ALL=C

CLUSTER_STATUS='pending'
echo "Waiting gluster cluster become available..."
while [[ ${CLUSTER_STATUS} != 'Running' ]]; do
  kubectl -n storage get pod
  CLUSTER_STATUS=$(kubectl \
  -n storage \
  {{ 'get pod -o go-template="{{range .items}}{{.status.phase}}{{\\"\\n\\"}}{{end}}"' }} \
  | sort | uniq)
  sleep 3
done


{% for node,spec in nodes.items() -%}
  {%- if spec.gluster %}kubectl get pod -n storage --selector glusterfs-node=pod -o json | \
    jq ".items[0].metadata.name" -r | \
    xargs -I{} kubectl exec -t {} gluster peer probe {{ node }}{% endif %}
{% endfor -%}
