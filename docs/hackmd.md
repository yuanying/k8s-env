# HackMD

## Install

### Prerequired resources

```bash
$ kubectl apply -R -f configs/manifests/hackmd
$ kubectl config set-context cluster --namespace hackmd
```

### Chart

```bash
$ ghq get hackmdio/docker-hackmd
$ cd $GOPATH/src/github.com/hackmdio/docker-hackmd/kubernetes/chart
$ helm dep up .
$ cd -
$ helm install $GOPATH/src/github.com/hackmdio/docker-hackmd/kubernetes/chart \
  --name hmd0 -f configs/helm/hackmd.yaml \
  --namespace hackmd
```
