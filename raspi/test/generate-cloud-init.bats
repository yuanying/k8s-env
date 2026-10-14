#!/usr/bin/env bats
# raspi/generate-cloud-init.sh のテスト
# 実行: bats raspi/test

setup() {
  RASPI_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
  OUT="${BATS_TEST_TMPDIR}/out"
  # 呼び出し元の環境に左右されないよう、テンプレートが読む変数を消しておく
  unset NODE_HOSTNAME NODE_ADDRESS NODE_PUBLIC_KEY NODE_GITHUB_USER \
        NODE_GATEWAY NODE_DNS NODE_NETWORK_RANGE NODE_NET_DEVICE
}

generate() {
  bash "${RASPI_DIR}/generate-cloud-init.sh" "$@"
}

ud() { yq -e "$1" "${OUT}/user-data"; }
nc() { yq -e "$1" "${OUT}/network-config"; }

@test "user-data と network-config を出力先に書く" {
  run generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$status" -eq 0 ]
  [ -f "${OUT}/user-data" ]
  [ -f "${OUT}/network-config" ]
}

@test "user-data は #cloud-config で始まる YAML である" {
  generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$(head -n1 "${OUT}/user-data")" = "#cloud-config" ]
  yq -e '.' "${OUT}/user-data" > /dev/null
  yq -e '.' "${OUT}/network-config" > /dev/null
}

@test "rasp01 はホスト名 rasp01、アドレス 192.168.1.111/16 になる" {
  generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$(ud '.hostname')" = "rasp01" ]
  [ "$(nc '.ethernets.eth0.addresses[0]')" = "192.168.1.111/16" ]
}

@test "rasp02 / rasp03 は .112 / .113 になる" {
  generate "${RASPI_DIR}/envs/rasp02.sh" "${OUT}"
  [ "$(ud '.hostname')" = "rasp02" ]
  [ "$(nc '.ethernets.eth0.addresses[0]')" = "192.168.1.112/16" ]

  generate "${RASPI_DIR}/envs/rasp03.sh" "${OUT}"
  [ "$(ud '.hostname')" = "rasp03" ]
  [ "$(nc '.ethernets.eth0.addresses[0]')" = "192.168.1.113/16" ]
}

@test "network-config は IPv4 固定、既定経路と DNS はルーター、IPv6 は RA で取る" {
  generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$(nc '.version')" = "2" ]
  [ "$(nc '.ethernets.eth0.dhcp4')" = "false" ]
  [ "$(nc '.ethernets.eth0.accept-ra')" = "true" ]
  [ "$(nc '.ethernets.eth0.routes[0].to')" = "default" ]
  [ "$(nc '.ethernets.eth0.routes[0].via')" = "192.168.0.1" ]
  [ "$(nc '.ethernets.eth0.nameservers.addresses[0]')" = "192.168.0.1" ]
  # netplan で非推奨の gateway4 は使わない
  ! grep -q gateway4 "${OUT}/network-config"
}

@test "SSH はユーザー ubuntu に GitHub の公開鍵で入れ、パスワードログインは無効" {
  generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$(ud '.users[0].name')" = "ubuntu" ]
  [ "$(ud '.users[0].ssh_import_id[0]')" = "gh:yuanying" ]
  [ "$(ud '.users[0].sudo')" = "ALL=(ALL) NOPASSWD:ALL" ]
  [ "$(ud '.users[0].lock_passwd')" = "true" ]
  [ "$(ud '.ssh_pwauth')" = "false" ]
}

@test "NODE_PUBLIC_KEY を渡すと authorized_keys にも入る" {
  NODE_PUBLIC_KEY="ssh-ed25519 AAAATEST test@example" \
    generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$(ud '.users[0].ssh_authorized_keys[0]')" = "ssh-ed25519 AAAATEST test@example" ]
}

@test "NODE_PUBLIC_KEY が無ければ ssh_authorized_keys は書かない" {
  generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$(yq '.users[0] | has("ssh_authorized_keys")' "${OUT}/user-data")" = "false" ]
}

@test "porkadot が前提にする containerd を apt で入れる" {
  generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  yq -e '.packages[] | select(. == "containerd")' "${OUT}/user-data" > /dev/null
}

@test "memory controller が無いときだけ cmdline に cgroup_enable=memory を足す（24.04 / 26.04 の両配置）" {
  generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  grep -q 'cgroup_enable=memory' "${OUT}/user-data"
  grep -q '/sys/fs/cgroup/cgroup.controllers' "${OUT}/user-data"
  # 26.04 は A/B ブートで current/ 配下、24.04 は直下
  grep -q '/boot/firmware/current/cmdline.txt' "${OUT}/user-data"
  grep -q '/boot/firmware/cmdline.txt' "${OUT}/user-data"
  # cgroup_memory=1 は現行 kernel では認識されない
  ! grep -q 'cgroup_memory=1' "${OUT}/user-data"
}

@test "cmdline の追記処理は memory が無いときだけ、実在する cmdline.txt に 1 回だけ足す" {
  generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  script=$(yq -e '.write_files[] | select(.path == "/usr/local/sbin/enable-memory-cgroup") | .content' "${OUT}/user-data")
  root="${BATS_TEST_TMPDIR}/root"

  # 26.04 配置、memory 無し → current/ に追記、2 回目は何もしない
  mkdir -p "${root}/boot/firmware/current" "${root}/sys/fs/cgroup"
  echo 'console=tty1 root=LABEL=writable rootwait' > "${root}/boot/firmware/current/cmdline.txt"
  echo 'cpuset cpu io pids' > "${root}/sys/fs/cgroup/cgroup.controllers"
  ROOT="${root}" bash -c "${script}"
  ROOT="${root}" bash -c "${script}"
  [ "$(cat "${root}/boot/firmware/current/cmdline.txt")" = "console=tty1 root=LABEL=writable rootwait cgroup_enable=memory" ]

  # 24.04 配置、memory 有り → 触らない
  root2="${BATS_TEST_TMPDIR}/root2"
  mkdir -p "${root2}/boot/firmware" "${root2}/sys/fs/cgroup"
  echo 'console=tty1 rootwait' > "${root2}/boot/firmware/cmdline.txt"
  echo 'cpuset cpu io memory pids' > "${root2}/sys/fs/cgroup/cgroup.controllers"
  ROOT="${root2}" bash -c "${script}"
  [ "$(cat "${root2}/boot/firmware/cmdline.txt")" = "console=tty1 rootwait" ]

  # 24.04 配置、memory 無し → 直下に追記
  echo 'cpuset cpu io pids' > "${root2}/sys/fs/cgroup/cgroup.controllers"
  ROOT="${root2}" bash -c "${script}"
  [ "$(cat "${root2}/boot/firmware/cmdline.txt")" = "console=tty1 rootwait cgroup_enable=memory" ]
}

@test "初回起動の最後に再起動する（cmdline とパッケージ更新を反映させる）" {
  generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$(ud '.power_state.mode')" = "reboot" ]
}

@test "検証機用 env は NODE_HOSTNAME と NODE_ADDRESS を外から受け取る" {
  NODE_HOSTNAME=rasp-verify NODE_ADDRESS=192.168.1.119 \
    generate "${RASPI_DIR}/envs/verify.sh" "${OUT}"
  [ "$(ud '.hostname')" = "rasp-verify" ]
  [ "$(nc '.ethernets.eth0.addresses[0]')" = "192.168.1.119/16" ]
}

@test "検証機用 env で NODE_ADDRESS が無ければ失敗する" {
  run env NODE_HOSTNAME=rasp-verify bash "${RASPI_DIR}/generate-cloud-init.sh" "${RASPI_DIR}/envs/verify.sh" "${OUT}"
  [ "$status" -ne 0 ]
  [[ "$output" == *NODE_ADDRESS* ]]
  [ ! -f "${OUT}/user-data" ]
}

@test "引数が足りなければ使い方を出して失敗する" {
  run generate
  [ "$status" -ne 0 ]
  [[ "$output" == *Usage* ]]
}
