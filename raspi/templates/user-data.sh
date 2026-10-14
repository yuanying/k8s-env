#!/usr/bin/env bash
set -eu
export LC_ALL=C

authorized_keys=''
if [[ -n ${NODE_PUBLIC_KEY} ]]; then
    authorized_keys="
  ssh_authorized_keys:
  - ${NODE_PUBLIC_KEY}"
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

package_update: true
package_upgrade: true
# porkadot は containerd を入れない（setup-containerd は設定を書くだけ）
packages:
- containerd

write_files:
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
