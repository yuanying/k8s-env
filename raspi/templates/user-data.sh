#!/usr/bin/env bash
set -eu
export LC_ALL=C

if [[ ! ${NODE_CONTAINERD_SERIES:-} =~ ^[0-9]+\.[0-9]+$ ]]; then
    echo "NODE_CONTAINERD_SERIES must be <major>.<minor> (e.g. 2.3): '${NODE_CONTAINERD_SERIES:-}'" >&2
    exit 1
fi

# NODE_PUBLIC_KEY、NODE_AUTHORIZED_KEYS_FILE、NODE_AUTHORIZED_KEYS_URL の順に鍵を集める
raw_keys="${NODE_PUBLIC_KEY:-}"
if [[ -n ${NODE_AUTHORIZED_KEYS_FILE:-} ]]; then
    if [[ ! -r ${NODE_AUTHORIZED_KEYS_FILE} ]]; then
        echo "cannot read NODE_AUTHORIZED_KEYS_FILE: ${NODE_AUTHORIZED_KEYS_FILE}" >&2
        exit 1
    fi
    raw_keys+=$'\n'$(cat "${NODE_AUTHORIZED_KEYS_FILE}")
fi
if [[ -n ${NODE_AUTHORIZED_KEYS_URL:-} ]]; then
    if ! fetched=$(curl -fsSL "${NODE_AUTHORIZED_KEYS_URL}"); then
        echo "failed to fetch keys from ${NODE_AUTHORIZED_KEYS_URL}" >&2
        exit 1
    fi
    if ! grep -q '[^[:space:]]' <<< "${fetched}"; then
        echo "no keys found at ${NODE_AUTHORIZED_KEYS_URL}" >&2
        exit 1
    fi
    raw_keys+=$'\n'${fetched}
fi

# 空行とコメント行を除き、前後の空白と CR を落とし、重複を除いて YAML の単一引用符で書く
authorized_keys=''
declare -A seen=()
while IFS= read -r key || [[ -n ${key} ]]; do
    key=${key%$'\r'}
    key=$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' <<< "${key}")
    [[ -z ${key} || ${key} == '#'* ]] && continue
    if [[ ! ${key} =~ ^(ssh-|ecdsa-|sk-) ]]; then
        echo "not a public key: ${key}" >&2
        exit 1
    fi
    [[ -n ${seen[${key}]:-} ]] && continue
    seen[${key}]=1
    authorized_keys+=$'\n'"  - '${key//\'/\'\'}'"
done <<< "${raw_keys}"
if [[ -n ${authorized_keys} ]]; then
    authorized_keys=$'\n'"  ssh_authorized_keys:${authorized_keys}"
fi

cat <<EOS
#cloud-config
hostname: ${NODE_HOSTNAME}
preserve_hostname: false
manage_etc_hosts: true
timezone: Asia/Tokyo

# 既定ユーザー ubuntu を置き換える。porkadot は ubuntu で SSH し、sudo で root になる
users:
- name: ubuntu
  groups: [adm, sudo]
  shell: /bin/bash
  sudo: "ALL=(ALL) NOPASSWD:ALL"
  lock_passwd: true
  ssh_import_id:
  - gh:${NODE_GITHUB_USER}${authorized_keys}
ssh_pwauth: false

# containerd は Docker の containerd.io を入れる。Ubuntu の containerd には新しい系列が無い。
# \$RELEASE は OS の codename、\$KEY_FILE は keyid の鍵の置き場所で、cloud-init が置き換える
apt:
  sources:
    docker:
      keyid: "9DC858229FC7DD38854AE2D88D81803C0EBFCD88"
      keyserver: "keyserver.ubuntu.com"
      source: "deb [arch=arm64 signed-by=\$KEY_FILE] https://download.docker.com/linux/ubuntu \$RELEASE stable"

package_update: true
package_upgrade: true
# porkadot は containerd を入れない（setup-containerd は設定を書くだけ）。
# containerd.io が置く config.toml（disabled_plugins = ["cri"]、version の行が無い）は、
# setup-containerd が控えを取って containerd config default から作り直すので、ここでは置かない
packages:
- containerd.io

write_files:
# pin しないと apt upgrade で次の系列に上がる。write_files はパッケージの導入より前に走る
- path: /etc/apt/preferences.d/containerd-io
  content: |
    Package: containerd.io
    Pin: version ${NODE_CONTAINERD_SERIES}.*
    Pin-Priority: 1001
# Ubuntu の linux-raspi は memory cgroup を既定で有効にしている（LP #2017209）。
# 無効だったときだけ cmdline に足す。cmdline.txt は 24.04 が直下、26.04 は A/B ブートの current/ にある
- path: /usr/local/sbin/enable-memory-cgroup
  permissions: "0755"
  content: |
    #!/bin/bash
    set -eu
    ROOT=\${ROOT:-}
    if grep -qw memory \${ROOT}/sys/fs/cgroup/cgroup.controllers; then
        exit 0
    fi
    for cmdline in \${ROOT}/boot/firmware/current/cmdline.txt \${ROOT}/boot/firmware/cmdline.txt; do
        if [[ -f \${cmdline} ]]; then
            grep -qw 'cgroup_enable=memory' \${cmdline} || sed -i '1 s/\$/ cgroup_enable=memory/' \${cmdline}
            exit 0
        fi
    done
    echo "cmdline.txt not found" >&2
    exit 1

runcmd:
- [ /usr/local/sbin/enable-memory-cgroup ]

# cmdline と kernel の更新を反映させる
power_state:
  mode: reboot
  message: "cloud-init finished, rebooting"
  condition: true
EOS
