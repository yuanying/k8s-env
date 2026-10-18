#!/usr/bin/env bats
# raspi/generate-cloud-init.sh のテスト
# 実行: bats raspi/test

setup() {
  RASPI_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
  OUT="${BATS_TEST_TMPDIR}/out"
  # 呼び出し元の環境に左右されないよう、テンプレートが読む変数を消しておく
  unset NODE_HOSTNAME NODE_ADDRESS NODE_PUBLIC_KEY NODE_GITHUB_USER \
        NODE_GATEWAY NODE_DNS NODE_NETWORK_RANGE NODE_NET_DEVICE \
        NODE_AUTHORIZED_KEYS_FILE NODE_AUTHORIZED_KEYS_URL NODE_CONTAINERD_SERIES

  # 生成時の鍵の取得をネットワークに出さないよう、curl を偽物に差し替える。
  # 偽の curl は取得した URL を記録し、FAKE_KEYS の中身を返す
  FAKE_BIN="${BATS_TEST_TMPDIR}/bin"
  mkdir -p "${FAKE_BIN}"
  export FAKE_KEYS="${BATS_TEST_TMPDIR}/fake-keys"
  export CURL_LOG="${BATS_TEST_TMPDIR}/curl.log"
  printf '%s\n' 'ssh-ed25519 AAAAGH1 gh-key-1' 'ssh-rsa AAAAGH2' > "${FAKE_KEYS}"
  cat > "${FAKE_BIN}/curl" <<'EOS'
#!/usr/bin/env bash
echo "${@: -1}" >> "${CURL_LOG}"
[[ -n ${FAKE_CURL_FAIL:-} ]] && exit 22
cat "${FAKE_KEYS}"
EOS
  chmod +x "${FAKE_BIN}/curl"
  export PATH="${FAKE_BIN}:${PATH}"
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

@test "鍵の指定がすべて空なら ssh_authorized_keys は書かない" {
  NODE_AUTHORIZED_KEYS_URL='' \
    generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$(yq '.users[0] | has("ssh_authorized_keys")' "${OUT}/user-data")" = "false" ]
}

@test "既定では生成時に GitHub の鍵を取得して authorized_keys に書き込む" {
  generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$(cat "${CURL_LOG}")" = "https://github.com/yuanying.keys" ]
  [ "$(ud '.users[0].ssh_authorized_keys | length')" = "2" ]
  [ "$(ud '.users[0].ssh_authorized_keys[0]')" = "ssh-ed25519 AAAAGH1 gh-key-1" ]
  [ "$(ud '.users[0].ssh_authorized_keys[1]')" = "ssh-rsa AAAAGH2" ]
  # ssh_import_id も従来どおり残す
  [ "$(ud '.users[0].ssh_import_id[0]')" = "gh:yuanying" ]
}

@test "取得先の既定は NODE_GITHUB_USER に従い、NODE_AUTHORIZED_KEYS_URL で差し替えられる" {
  NODE_GITHUB_USER=someone generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$(tail -n1 "${CURL_LOG}")" = "https://github.com/someone.keys" ]

  NODE_AUTHORIZED_KEYS_URL=https://example.com/keys generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$(tail -n1 "${CURL_LOG}")" = "https://example.com/keys" ]
}

@test "NODE_AUTHORIZED_KEYS_URL を空にすると取得しない" {
  NODE_AUTHORIZED_KEYS_URL='' generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ ! -f "${CURL_LOG}" ]
}

@test "鍵の取得に失敗したら生成も失敗し、何も書かない" {
  run env FAKE_CURL_FAIL=1 bash "${RASPI_DIR}/generate-cloud-init.sh" "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$status" -ne 0 ]
  [[ "$output" == *github.com/yuanying.keys* ]]
  [ ! -f "${OUT}/user-data" ]
}

@test "取得した中身に鍵が 1 本も無ければ失敗する" {
  : > "${FAKE_KEYS}"
  run bash "${RASPI_DIR}/generate-cloud-init.sh" "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$status" -ne 0 ]
  [ ! -f "${OUT}/user-data" ]
}

@test "鍵に見えない行があれば失敗する（HTML のエラーページなどを書き込まない）" {
  printf '%s\n' '<!DOCTYPE html>' '<html>' > "${FAKE_KEYS}"
  run bash "${RASPI_DIR}/generate-cloud-init.sh" "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$status" -ne 0 ]
  [[ "$output" == *DOCTYPE* ]]
  [ ! -f "${OUT}/user-data" ]
}

@test "NODE_AUTHORIZED_KEYS_FILE の鍵を全部書き込む（空行・コメント行・CRLF・末尾改行なしを扱う）" {
  keys="${BATS_TEST_TMPDIR}/keys"
  printf '# 作業端末\n\nssh-ed25519 AAAAF1 me@laptop one\r\n   \n  # indented comment\necdsa-sha2-nistp256 AAAAF2 "quoted" it'"'"'s: #x\nsk-ssh-ed25519@openssh.com AAAAF3' > "${keys}"
  NODE_AUTHORIZED_KEYS_URL='' NODE_AUTHORIZED_KEYS_FILE="${keys}" \
    generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$(ud '.users[0].ssh_authorized_keys | length')" = "3" ]
  [ "$(ud '.users[0].ssh_authorized_keys[0]')" = "ssh-ed25519 AAAAF1 me@laptop one" ]
  [ "$(ud '.users[0].ssh_authorized_keys[1]')" = "ecdsa-sha2-nistp256 AAAAF2 \"quoted\" it's: #x" ]
  [ "$(ud '.users[0].ssh_authorized_keys[2]')" = "sk-ssh-ed25519@openssh.com AAAAF3" ]
  python3 -c 'import sys, yaml; yaml.safe_load(open(sys.argv[1]))' "${OUT}/user-data"
}

@test "NODE_AUTHORIZED_KEYS_FILE が読めなければ失敗する" {
  run env NODE_AUTHORIZED_KEYS_FILE="${BATS_TEST_TMPDIR}/missing" \
    bash "${RASPI_DIR}/generate-cloud-init.sh" "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$status" -ne 0 ]
  [[ "$output" == *missing* ]]
  [ ! -f "${OUT}/user-data" ]
}

@test "NODE_PUBLIC_KEY・ファイル・URL の鍵をこの順にまとめ、重複は 1 本にする" {
  keys="${BATS_TEST_TMPDIR}/keys"
  printf '%s\n' 'ssh-ed25519 AAAAF1 file' 'ssh-ed25519 AAAAGH1 gh-key-1' > "${keys}"
  NODE_PUBLIC_KEY="ssh-ed25519 AAAAP1 pub" NODE_AUTHORIZED_KEYS_FILE="${keys}" \
    generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$(ud '.users[0].ssh_authorized_keys | length')" = "4" ]
  [ "$(ud '.users[0].ssh_authorized_keys[0]')" = "ssh-ed25519 AAAAP1 pub" ]
  [ "$(ud '.users[0].ssh_authorized_keys[1]')" = "ssh-ed25519 AAAAF1 file" ]
  [ "$(ud '.users[0].ssh_authorized_keys[2]')" = "ssh-ed25519 AAAAGH1 gh-key-1" ]
  [ "$(ud '.users[0].ssh_authorized_keys[3]')" = "ssh-rsa AAAAGH2" ]
}

@test "porkadot が前提にする containerd は Docker の containerd.io を入れ、Ubuntu の containerd は入れない" {
  generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  yq -e '.packages[] | select(. == "containerd.io")' "${OUT}/user-data" > /dev/null
  [ "$(yq '[.packages[] | select(. == "containerd" or . == "runc")] | length' "${OUT}/user-data")" = "0" ]
}

@test "Docker の arm64 のリポジトリを、OS の codename と固定した鍵の指紋で足す" {
  generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  # $RELEASE と $KEY_FILE は cloud-init が初回起動時に置き換える
  [ "$(ud '.apt.sources.docker.source')" = 'deb [arch=arm64 signed-by=$KEY_FILE] https://download.docker.com/linux/ubuntu $RELEASE stable' ]
  [ "$(ud '.apt.sources.docker.keyid')" = "9DC858229FC7DD38854AE2D88D81803C0EBFCD88" ]
  [ "$(ud '.apt.sources.docker.keyserver')" = "keyserver.ubuntu.com" ]
}

@test "containerd.io を既定で 2.3 系に pin する" {
  generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  pin=$(ud '.write_files[] | select(.path == "/etc/apt/preferences.d/containerd-io") | .content')
  [ "${pin}" = $'Package: containerd.io\nPin: version 2.3.*\nPin-Priority: 1001' ]
}

@test "pin する系列は NODE_CONTAINERD_SERIES で変えられる" {
  NODE_CONTAINERD_SERIES=2.4 generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  ud '.write_files[] | select(.path == "/etc/apt/preferences.d/containerd-io") | .content' | grep -qx 'Pin: version 2.4.\*'
}

@test "NODE_CONTAINERD_SERIES が <major>.<minor> でなければ失敗する" {
  for series in 2 2.3.6 '2.*' 'v2.3'; do
    run env NODE_CONTAINERD_SERIES="${series}" bash "${RASPI_DIR}/generate-cloud-init.sh" "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
    [ "$status" -ne 0 ]
    [[ "$output" == *NODE_CONTAINERD_SERIES* ]]
    [ ! -f "${OUT}/user-data" ]
  done
}

@test "containerd の config.toml は置かない（porkadot の setup-containerd が作り直す）" {
  generate "${RASPI_DIR}/envs/rasp01.sh" "${OUT}"
  [ "$(yq '[.write_files[] | select(.path == "/etc/containerd/config.toml")] | length' "${OUT}/user-data")" = "0" ]
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
