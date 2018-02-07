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
$ helm install $GOPATH/src/github.com/yuanying/charts/incubator/hackmd \
  --name hmd0 -f configs/helm/hackmd.yaml \
  --namespace hackmd
```

## Update

```bash
$ helm upgrade hmd0 $GOPATH/src/github.com/yuanying/charts/incubator/hackmd \
  -f configs/helm/hackmd.yaml --force
```
