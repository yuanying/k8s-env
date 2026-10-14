# control-plane の OS 選定（Ubuntu 24.04 LTS / 26.04 LTS）

Raspberry Pi 5（8GB、NVMe 起動）で Kubernetes v1.29.8 の control-plane（etcd の static pod と self-hosted の apiserver など）を動かす前提で、
2 つの LTS を机上で比べた結果。調べたのは 2026-10-14 時点の配布物で、最終判断は検証機での試験で行う。

確認方法の記号:

- 【実測】cdimage のイメージを展開して中身を見た、または Launchpad の公開情報を直接引いた
- 【文書】公式ドキュメントの記述
- 【未検証】確認できていない。検証機で確かめる

## 比較

| 項目 | 24.04 LTS（noble） | 26.04 LTS（resolute） |
|---|---|---|
| Raspberry Pi 向け公式イメージ | `ubuntu-24.04.5-preinstalled-server-arm64+raspi.img.xz`（2026-09 公開）【実測】 | `ubuntu-26.04.1-preinstalled-server-arm64+raspi.img.xz`（2026-08 公開）【実測】 |
| Pi 5 のサポート | 対象。Pi 5 に対応した最初の LTS【文書】 | 対象【文書】 |
| EEPROM の条件（Pi 5） | 指定なし【文書】 | 2025-02-11 以降が必須【文書】 |
| kernel（linux-raspi） | 6.8 系。updates / security は 6.8.0-1065【実測】 | 7.0 系。updates / security は 7.0.0-1020【実測】 |
| ページサイズ | 4K【実測】 | 4K【実測】 |
| containerd（apt の `containerd`、ソースは `containerd-app`） | release は 1.7.12、**updates / security は 2.2.1**（2026-04 に 1.7 系から上がった）【実測】 | release は 2.2.2、updates / security は 2.2.2-0ubuntu1.1【実測】 |
| cgroup | v2 が既定 | v2 のみ（systemd 259 で v1 を削除）【文書・実測】 |
| memory cgroup | 既定で有効。kernel に `cgroup_enable=` 自体が無い【実測】 | おそらく既定で有効。kernel に `cgroup_enable=` があるので、無効化の仕組みが残っている可能性がある【未検証】 |
| cmdline.txt の場所 | `/boot/firmware/cmdline.txt` | `/boot/firmware/current/cmdline.txt`（A/B ブートに変わった）【実測・文書】 |
| vxlan / overlay / br_netfilter など | 標準の modules パッケージに含まれる。`linux-modules-extra-raspi` は無い（不要）【実測】 | 同じ【実測】 |
| sudo / coreutils | 従来の sudo と GNU coreutils | **sudo-rs と Rust 版 coreutils が既定**【文書】 |
| 標準サポートの期限 | 2029 年 4 月 | 2031 年 4 月 |

## 両方に共通すること

- **containerd はどちらを選んでも 2.2 系になる。** 24.04 でも、apt の updates から 2.2.1 が入る。
  したがって OS の選択は porkadot の containerd v2 対応の要否に影響しない。どちらでも対応が先に要る。
- cloud-init の seed（`user-data` / `network-config`）は、どちらも boot パーティション（`system-boot`）に置く。
  イメージ同梱の `network-config` は `eth0` の DHCP だけ。
- Ubuntu の kernel は 4K ページなので、Raspberry Pi OS の Pi 5 向け kernel（16K ページ）で起きる
  「jemalloc を使う arm64 イメージが落ちる」問題は起きない。
- NVMe から起動するには、EEPROM のブート順を NVMe 優先（`BOOT_ORDER=0xf416`）にする。
  公式 M.2 HAT+ なら `PCIE_PROBE` や `dtparam=pciex1` は要らない。

## 見立て: 24.04 を推奨する

**24.04.5 を推奨する。** 理由は次のとおり。

1. **K8s v1.29.8 と同じ時期の土台である。** v1.29 は 2024 年の版で、kernel 6.8 / systemd 255 の 24.04 と同じ時期に出ている。
   26.04 の kernel 7.0 / systemd 259 と v1.29 の組み合わせは、上流でも試されていない可能性が高い。
   このタスクでは K8s を上げないので、組み合わせの新しさがそのままリスクになる。
2. **porkadot の動かし方と 26.04 の変更がぶつかりうる。** porkadot は SSH で sudo し、シェルスクリプト（`cp`、`ln`、`mktemp`、`tar` など）でノードを設定する。
   26.04 は sudo を sudo-rs に、coreutils を Rust 版に入れ替えた。動く見込みは高いが、差異が出たときの切り分けが増える。
3. **ブート方式の変更が新しい。** 26.04 の A/B ブート（`current/` `new/` `old/`）は 2026-04 に入ったばかりで、
   kernel 更新時の挙動に実績が少ない。control-plane の 3 台が同じ不具合を同時に踏むと、復旧が難しい。
4. **containerd の版は変わらない。** 26.04 を選んでも containerd は同じ 2.2 系で、得られるものはサポート期限の延長だけになる。

26.04 を選ぶ理由になるのは、**サポート期限が 2 年長い**ことである。24.04 は 2029 年 4 月に標準サポートが終わるので、
それまでにもう一度 OS 更新（`do-release-upgrade` か、再度の入れ替え）が要る。
とはいえ、そのころには K8s を何マイナーも上げているはずで、OS 更新はその計画の中で行えばよい。

迷う場合は、検証機で 24.04 を本命として試し、余力があれば 26.04 でも `setup-node` から `install kubelet` まで通るかを確かめて比べる。

## 検証機で確かめること

- memory controller が既定で有効か（`/sys/fs/cgroup/cgroup.controllers` に `memory`）。特に 26.04
- 24.04 で kernel を更新したとき、flash-kernel が `/boot/firmware/cmdline.txt` を上書きしないか（追記した場合のみ関係する）
- 26.04 を試す場合: porkadot の `setup-node` / `setup-containerd` / `install kubelet` が sudo-rs と Rust 版 coreutils の上で通るか
- NVMe から起動して、cloud-init が最後まで終わるか（`cloud-init status --long`）

## 未検証のまま残っていること

- 26.04 の linux-raspi で memory controller が実際に既定で有効か
- 24.04 で flash-kernel が `cmdline.txt` を上書きするか
- 24.04 の containerd を 1.7 系に固定する方法があるか（2.x 前提で進めるので、必要になる見込みは低い）
- Pi 5 の NVMe 起動に必要な 24.04 の最小ポイントリリース（24.04.5 を使うので実害は無い）
- Imager で書いた Ubuntu イメージから NVMe で起動できることの公式な明記
- イメージ同梱の `meta-data` の中身

## 出典

- イメージ一覧: <https://cdimage.ubuntu.com/releases/24.04/release/>、<https://cdimage.ubuntu.com/releases/26.04/release/>、<https://cdimage.ubuntu.com/releases/20.04/release/>
- Raspberry Pi のサポート表と EEPROM の条件: <https://ubuntu.com/hardware/docs/boards/how-to/ubuntu_supported/raspberry-pi/>
- 26.04 の変更点: <https://documentation.ubuntu.com/release-notes/26.04/summary-for-lts-users/>
- 24.04 のリリースノート: <https://documentation.ubuntu.com/release-notes/24.04/>
- 26.04 の A/B ブート: <https://ubuntu.com/hardware/docs/boards/explanations/piboot-ab/>
- containerd の版: <https://launchpad.net/ubuntu/+source/containerd-app>、
  <https://changelogs.ubuntu.com/changelogs/pool/main/c/containerd-app/containerd-app_2.2.1-0ubuntu1~24.04.3/changelog>
- kernel モジュールの一覧: <https://packages.ubuntu.com/noble-updates/arm64/linux-modules-6.8.0-1065-raspi/filelist>、
  <https://packages.ubuntu.com/resolute-updates/arm64/linux-modules-7.0.0-1020-raspi/filelist>
- Ubuntu が memory cgroup の無効化パッチを戻した件: <https://bugs.launchpad.net/bugs/2017209>
- Raspberry Pi OS の memory cgroup: <https://github.com/raspberrypi/linux/issues/6980>
- Pi 5 の NVMe 起動と EEPROM: <https://github.com/raspberrypi/documentation/blob/master/documentation/asciidoc/computers/raspberry-pi/pcie.adoc>（同じディレクトリの `eeprom-bootloader.adoc`、`boot-nvme.adoc`）、
  <https://github.com/raspberrypi/documentation/blob/master/documentation/asciidoc/accessories/m2-hat-plus/about.adoc>
- Pi 5 のページサイズ: <https://pimylifeup.com/raspberry-pi-page-size/>
- 旧来の手順（cmdline と `linux-modules-extra-raspi`）: <https://canonical.com/microk8s/docs/install-raspberry-pi>
