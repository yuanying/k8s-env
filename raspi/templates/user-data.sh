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

runcmd:
# memory cgroup を有効にする。Raspberry Pi の kernel は既定で無効にしている
- [ sh, -c, "grep -q 'cgroup_enable=memory' /boot/firmware/cmdline.txt || sed -i '1 s/\$/ cgroup_enable=memory cgroup_memory=1/' /boot/firmware/cmdline.txt" ]

# cmdline と kernel の更新を反映させる
power_state:
  mode: reboot
  message: "cloud-init finished, rebooting"
  condition: true
EOS
