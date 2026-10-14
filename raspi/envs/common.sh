#!/usr/bin/env bash
# control-plane 用 Raspberry Pi 共通の設定。各ノードの env から source する。

export NODE_GITHUB_USER=${NODE_GITHUB_USER:-'yuanying'}
export NODE_NETWORK_RANGE=${NODE_NETWORK_RANGE:-'16'}
export NODE_GATEWAY=${NODE_GATEWAY:-'192.168.0.1'}
export NODE_DNS=${NODE_DNS:-'192.168.0.1'}
export NODE_NET_DEVICE=${NODE_NET_DEVICE:-'eth0'}
# 追加で authorized_keys に入れる公開鍵（任意）。GitHub の鍵は ssh_import_id で入る
export NODE_PUBLIC_KEY=${NODE_PUBLIC_KEY:-''}
