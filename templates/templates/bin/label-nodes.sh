#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

{% for node,spec in nodes.items() -%}
  {%- for key,value in spec.labels.items() -%}
kubectl label node {{ node }} {{ key }}={{ value }}
  {%- endfor %}
{% endfor -%}
