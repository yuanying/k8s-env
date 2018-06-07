# Nginx Ingress Controller

## Install

### Namespace

```bash
$ kubectl apply -f manifests/namespaces/nginx-ingress-controller.yaml
$ kubectl config set-context cluster --namespace ingress
```

### Deploy nginx-ingress controller

```bash
$ bash bin/nginx-label-ingress-node.sh
$ helm install -n ing stable/nginx-ingress \
  --version 0.20.1 \
  -f configs/helm/nginx-ingress.yaml \
  --namespace ingress
$ helm install -n certs stable/kube-lego \
  -f helm/kube-lego.yaml \
  --namespace ingress
```

## Update

```bash
$ helm upgrade ing stable/nginx-ingress \
  --version 0.20.1 \
  -f configs/helm/nginx-ingress.yaml \
  --recreate-pods
$ helm upgrade certs stable/kube-lego \
  -f helm/kube-lego.yaml --recreate-pods
```
