# Metallb

## Install

### Namespace

```bash
$ kubectl apply -f manifests/namespaces/metallb.yaml
$ kubectl config set-context cluster --namespace metallb
```

### Deploy nginx-ingress controller

```bash
$ helm install -n mlb0 stable/metallb \
  --version 0.6.0 \
  -f configs/helm/metallb.yaml \
  --namespace metallb
```

## Update

```bash
$ helm upgrade mlb0 stable/metallb \
  --version 0.6.1 \
  -f configs/helm/metallb \
  --recreate-pods
```
