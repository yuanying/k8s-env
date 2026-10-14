# Raspberry Pi control-plane のセットアップ

本番クラスタ `fraction` の control-plane（rasp01〜03、192.168.1.111〜113）を Raspberry Pi 5 に載せ替えるとき、
新しい機体を **porkadot の `setup-node` に渡せる状態** まで作る手順。
etcd メンバーの入れ替えや porkadot の操作は、この手順の範囲外である（交換手順書の側で扱う）。

- 機体: Raspberry Pi 5（8GB）、M.2 HAT+ 経由の NVMe SSD から起動する
- OS: Ubuntu Server の Raspberry Pi 向け preinstalled イメージ。24.04 LTS / 26.04 LTS のどちらでも通るように書いてあり、
  違う箇所はその場で明記する。どちらを選ぶかの検討は [os-selection.md](os-selection.md) にある
- 初期設定は cloud-init で入れる。設定ファイルは `raspi/generate-cloud-init.sh` で生成する

## 仕上がりの状態

この手順を終えると、新しい機体は次の状態になる。porkadot はこの状態を前提にしている。

| 項目 | 状態 | 理由 |
|---|---|---|
| ホスト名 | rasp01〜03（検証機は任意） | 現行と同じ通称に揃える |
| IPv4 | 192.168.1.111〜113/16 を固定で持つ。既定経路と DNS は 192.168.0.1 | porkadot の `porkadot.yaml` はノードを IP で引く |
| IPv6 | ルーターの RA で SLAAC アドレスを取る | クラスタはデュアルスタック |
| SSH | ユーザー `ubuntu` に GitHub（`gh:yuanying`）の公開鍵で入れる。鍵は生成時に `user-data` へ書き込むので、初回起動で GitHub に届かなくても入れる。パスワードログインは無効 | `porkadot.yaml` の control-plane は `connection: { user: ubuntu }` |
| sudo | `ubuntu` はパスワードなしで sudo できる | porkadot は SSH 先で sudo して root で実行する |
| containerd | Ubuntu の apt から入っている（どちらの OS でも 2.2 系） | porkadot は containerd を入れない。`setup-containerd` は設定を書くだけ |
| memory cgroup | 有効（cgroup v2） | kubelet が必要とする |
| パッケージ | 初回起動時に `apt upgrade` 済み | — |

## 1. 用意するもの

- Raspberry Pi 5（8GB）、公式 M.2 HAT+（または HAT+ 規格に準拠した NVMe 基板）、NVMe SSD
- 作業用の microSD カード 1 枚（EEPROM の更新にだけ使う）
- NVMe SSD に書き込む手段。次のどちらか
  - USB-NVMe 変換アダプタ（PC から直接書く）
  - SD から起動した Pi 5 自身（Pi 上で Raspberry Pi Imager を動かして NVMe に書く。Raspberry Pi 公式の手順はこちら）
- 有線 LAN。cloud-init の network-config は `eth0` だけを設定する

## 2. EEPROM を更新し、NVMe から起動するように設定する

機体ごとに 1 回だけ行う。

1. Raspberry Pi Imager で、作業用 SD に「Misc utility images → Bootloader (Pi 5 family) → NVMe/USB Boot」を書く。
2. その SD を挿して Pi 5 の電源を入れる。EEPROM が最新版に更新され、ブート順が NVMe 優先になる。
   画面が緑一色になるか、緑の LED が規則正しく点滅したら完了なので、電源を切って SD を抜く。
3. Imager を使えない場合は、Raspberry Pi OS Lite を SD から起動し、`sudo rpi-eeprom-update -a` で更新したうえで、
   `sudo rpi-eeprom-config --edit` で `BOOT_ORDER=0xf416`（NVMe → SD → USB の順）にする。

注意点:

- **26.04 を使う場合は、EEPROM の日付が 2025-02-11 以降であることが必須。** 上の手順で最新にしておけば満たす。
- 公式 M.2 HAT+ のような HAT+ 準拠の基板は自動で認識されるので、`PCIE_PROBE=1` や `config.txt` の `dtparam=pciex1` は要らない。
  HAT+ に準拠していない基板を使うときだけ必要になる。
- PCIe Gen3（`dtparam=pciex1_gen=3`）は有効にしない。Pi 5 は Gen3 の認証を受けておらず、公式も不安定になりうると書いている。
  etcd の書き込み性能は Gen2 で十分である。

## 3. OS イメージを NVMe SSD に書く

1. イメージを取得し、同じディレクトリの `SHA256SUMS` で検証する。
   - 24.04: `https://cdimage.ubuntu.com/ubuntu/releases/24.04/release/` の `ubuntu-24.04.5-preinstalled-server-arm64+raspi.img.xz`
   - 26.04: `https://cdimage.ubuntu.com/ubuntu/releases/26.04/release/` の `ubuntu-26.04.1-preinstalled-server-arm64+raspi.img.xz`
   - 新しいポイントリリースが出ていればそれを使う。ポイントリリースのほうが更新済みの kernel と firmware を含むので、初回起動が確実になる。
2. NVMe SSD に書く。
   - Imager で書く場合は「Use custom」でイメージを選ぶ。**Imager の OS カスタマイズ（ホスト名、ユーザー、SSH 鍵の設定）は使わない。**
     カスタマイズは boot パーティションの `user-data` を書き換えるので、次の手順で置く設定と衝突する。
   - PC から USB-NVMe アダプタ経由で `xzcat` と `dd` で書いてもよい。書き込み先のデバイス名は `lsblk` で必ず確かめる。

## 4. cloud-init の設定を置く

1. 機体の設定を生成する。出力先は `raspi/out/`（git の管理対象外）にする。
   - 本番機: `bash raspi/generate-cloud-init.sh raspi/envs/rasp01.sh raspi/out/rasp01`（rasp02 / rasp03 も同様）
   - 本番投入前の単体検証機: ホスト名と仮の空きアドレスを環境変数で渡す。
     `NODE_HOSTNAME=rasp-verify NODE_ADDRESS=192.168.1.<空き> bash raspi/generate-cloud-init.sh raspi/envs/verify.sh raspi/out/verify`
   - 生成時に `https://github.com/yuanying.keys` から公開鍵を取得し、全部を `user-data` に書き込む。
     取得に失敗したとき、鍵が 1 本も無いとき、鍵に見えない行が混じっていたときは、生成自体が失敗する。
     生成にはインターネットにつながった作業端末が要る。
   - 公開鍵の渡し方は次の 3 つで、併用できる。重複は 1 本にまとめる。

     | 環境変数 | 中身 | 既定値 |
     |---|---|---|
     | `NODE_AUTHORIZED_KEYS_URL` | 生成時に取得する鍵の URL。空にすると取得しない | `https://github.com/${NODE_GITHUB_USER}.keys` |
     | `NODE_AUTHORIZED_KEYS_FILE` | 鍵のファイル。1 行 1 鍵、空行と `#` で始まる行は無視する | なし |
     | `NODE_PUBLIC_KEY` | 鍵 1 行 | なし |

     例: GitHub に無い鍵を足す場合は `NODE_AUTHORIZED_KEYS_FILE=~/.ssh/extra.pub bash raspi/generate-cloud-init.sh ...`、
     GitHub から取らずにファイルの鍵だけにする場合はさらに `NODE_AUTHORIZED_KEYS_URL=` を付ける。
   - これとは別に、初回起動時に cloud-init が `ssh_import_id`（`gh:yuanying`）で GitHub の鍵を取りに行く。
     GitHub に届けば、生成後に GitHub へ足した鍵もここで入る。届かなくても、書き込み済みの鍵で入れる。
2. 書き込んだ NVMe SSD の boot パーティション（FAT、ラベル `system-boot`）をマウントし、生成した `user-data` と `network-config` で
   既存の同名ファイルを上書きする。`meta-data` はイメージのものをそのまま残す。
   - boot パーティションの場所は 24.04 / 26.04 で同じ。cloud-init は常にここを読む。

生成される設定の中身:

- `user-data`: ホスト名、タイムゾーン（Asia/Tokyo）、`ubuntu` ユーザー（生成時に書き込んだ鍵と `ssh_import_id`、NOPASSWD sudo、パスワードはロック）、
  `apt update` / `apt upgrade`、`containerd` の導入、memory cgroup の確認、最後に再起動
- `network-config`: `eth0` に IPv4 を固定で付け、既定経路と DNS をルーター（192.168.0.1）に向ける。IPv6 は RA を受ける
- memory cgroup: Ubuntu の Raspberry Pi 向け kernel は既定で有効にしているので、通常は何もしない。
  初回起動の時点で無効だった場合に限り、kernel の cmdline に `cgroup_enable=memory` を足す。
  cmdline.txt の場所は **24.04 が `/boot/firmware/cmdline.txt`、26.04 が `/boot/firmware/current/cmdline.txt`**（A/B ブートに変わったため）で、
  生成されるスクリプトはどちらにも対応している

## 5. 初回起動

1. **同じ IP を持つ旧機体が動いている間は、新しい機体をネットワークにつながない。** IP が衝突する。
   本番機を作るのは、交換手順書で旧機体を止めたあとにする。検証機は仮の空きアドレスで作るので、いつでもよい。
2. SD を抜き、NVMe SSD だけの状態で電源を入れる。
3. cloud-init がパッケージを更新し、最後に 1 回再起動する。数分から十数分かかる。
4. 旧機体の MAC アドレスで、ルーター（jumelle）に静的 DHCP の割り当てが残っている場合は、整理しておく。
   新しい機体は IP を固定で持つので割り当てが無くても動くが、旧機体を戻したときに混乱しないよう、割り当ての有無を確かめておく。

## 6. 確認する

作業端末から SSH で入って確かめる。同じ IP で機体が変わるので、先に `ssh-keygen -R 192.168.1.111` で古いホスト鍵を消しておく。

| 確認すること | 方法 | 期待する結果 |
|---|---|---|
| cloud-init が終わったか | `cloud-init status --long` | `status: done`、エラーなし |
| ホスト名と IP | `hostname`、`ip -br addr show eth0` | rasp0N、192.168.1.11N/16 と IPv6 の SLAAC アドレス |
| NVMe から起動しているか | `findmnt /` | `/dev/nvme0n1p2` |
| パスワードなしで sudo できるか | `sudo -n true` | 何も出ずに終わる |
| cgroup v2 と memory controller | `stat -fc %T /sys/fs/cgroup`、`cat /sys/fs/cgroup/cgroup.controllers` | `cgroup2fs`、`memory` を含む |
| containerd | `containerd --version`、`systemctl is-active containerd` | 2.2 系、`active` |
| swap が無いか | `swapon --show` | 何も出ない |
| ページサイズ | `getconf PAGESIZE` | `4096`（Ubuntu の kernel は 4K ページ。Raspberry Pi OS の Pi 5 向け kernel は 16K なので混同しない） |
| 時刻同期 | `timedatectl` | `System clock synchronized: yes` |
| OS と kernel | `cat /etc/os-release`、`uname -r` | 選んだ OS。kernel は 24.04 が 6.8 系、26.04 が 7.0 系 |

すべて期待どおりなら、porkadot の `setup-node` / `setup-containerd` / `install kubelet` に進める。

## 7. 次の工程に渡す前の注意

- **containerd は 2.2 系が入る。** 24.04 でも noble-updates の containerd は 2026-04 に 1.7 系から 2.2 系へ上がっている。
  porkadot の `setup-containerd` が containerd 2.x の config（version 3）に対応するまでは、`setup-containerd` を流しても
  `SystemdCgroup = true` が効かない。porkadot 側の対応（refactoring01/09）が入った版を使うこと。
- 26.04 は `sudo` が sudo-rs、coreutils が Rust 版に変わっている。porkadot は sudo とシェルスクリプトでノードを設定するので、
  26.04 を選ぶ場合は検証機で `setup-node` から `install kubelet` まで通ることを先に確かめる。

## 現行機（Ubuntu 20.04、Pi 4）の作り方について

k8s-env には Raspberry Pi 向けの資産（cloud-init の設定、イメージ、手順）が残っていない。
`tools/` にあるのは KVM の VM 用（amd64 の cloud image と NoCloud の ISO）だけである。

現行機は、20.04 の preinstalled server イメージ（cdimage に残っている最終版は 20.04.5）を SD に書き、
boot パーティションの `user-data` で初期設定した、と推定している。根拠は次の 3 点。

- SSH ユーザーが既定の `ubuntu` のまま（`yuanying` ユーザーが無い）
- kernel が `5.4.0-raspi`（preinstalled イメージの kernel）
- containerd が 1.6.20 で、Ubuntu の focal の版と一致しない。VM 用の `tools/templates/cloud-config-ubuntu.yaml` と同じく、
  Docker の apt リポジトリから `containerd.io` を入れたとみられる

確かめるには、旧機体で `/boot/firmware/user-data`、`/boot/firmware/cmdline.txt`、`/etc/netplan/`、`apt-cache policy containerd.io` を見る。
新しい機体では Docker のリポジトリを使わず、Ubuntu の `containerd` を使う。
Ubuntu の版で 2.x が手に入り、apt の追加リポジトリを管理しなくて済むからである。
