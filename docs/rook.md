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
$ helm install rook-master/rook -n rook \
  -f helm/rook.yaml \
  --version v0.7.0-102.gd6141bb \
  --namespace rook-system
```

### Create cluster

```bash
$ kubectl apply -f configs/manifests/rook/
```
