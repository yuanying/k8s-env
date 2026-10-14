#!/usr/bin/env bash
# control-plane 用 Raspberry Pi 共通の設定。各ノードの env から source する。

export NODE_GITHUB_USER=${NODE_GITHUB_USER:-'yuanying'}
export NODE_NETWORK_RANGE=${NODE_NETWORK_RANGE:-'16'}
export NODE_GATEWAY=${NODE_GATEWAY:-'192.168.0.1'}
export NODE_DNS=${NODE_DNS:-'192.168.0.1'}
export NODE_NET_DEVICE=${NODE_NET_DEVICE:-'eth0'}
# 以下の鍵は生成時に user-data の ssh_authorized_keys へ直接書き込む。
# ssh_import_id は初回起動時に GitHub へ取りに行くので、届かないと入れなくなる。それに備える
# 追加の公開鍵 1 本（任意）
export NODE_PUBLIC_KEY=${NODE_PUBLIC_KEY:-''}
# 公開鍵のファイル（任意）。1 行 1 鍵、空行と # で始まる行は無視する
export NODE_AUTHORIZED_KEYS_FILE=${NODE_AUTHORIZED_KEYS_FILE:-''}
# 生成時に取得する公開鍵の URL。空にすると取得しない
export NODE_AUTHORIZED_KEYS_URL=${NODE_AUTHORIZED_KEYS_URL-"https://github.com/${NODE_GITHUB_USER}.keys"}
