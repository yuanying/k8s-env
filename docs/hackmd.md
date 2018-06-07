# HackMD

## Install

### Prerequired resources

```bash
$ kubectl apply -R -f configs/manifests/hackmd
$ kubectl config set-context cluster --namespace hackmd
```

### Chart

```bash
$ ghq get yuanying/charts
$ cd $GOPATH/src/github.com/yuanying/charts/incubator/hackmd/
$ helm dep up .
$ cd -
$ helm install stable/hackmd \
  --name hmd0 -f configs/helm/hackmd.yaml \
  --namespace hackmd
```

## Update

```bash
$ helm upgrade hmd0 stable/hackmd \
  -f configs/helm/hackmd.yaml --force
```
