# Rook

## Install

### Namespace

```bash
$ kubectl apply -f manifests/namespaces/rook.yaml
$ kubectl config set-context cluster --namespace rook-system
```

### Mount storage devices

```bash
$ fab -f fabric/fabfile.py cluster mount
```

### Chart

```bash
$ helm repo add rook-master https://charts.rook.io/master
```
### Deploy rook-operator

```bash
$ helm install rook-master/rook-ceph -n ro0 \
  -f helm/rook.yaml \
  --version v0.7.0-184.gb4e9eba \
  --namespace rook-ceph-system
```

### Create cluster

```bash
$ kubectl apply -f configs/manifests/rook/
```

### Upgrade rook-operator

```bash
$ helm upgrade ro0 \
  rook-master/rook-ceph \
  --version v0.7.0-184.gb4e9eba \
  -f helm/rook.yaml
```