# Docker Gitlab

## Prerequisites

```bash
$ kubectl apply -f configs/manifests/docker-gitlab
```

## Install

### Switch Namespace

```bash
$ kubectl config set-context cluster --namespace gitlab
```

### docker-gitlab

```bash
$ ghq get yuanying/docker-gitlab
$ cd $GOPATH/src/github.com/yuanying/docker-gitlab/
$ git checkout add-helm-chart
$ cd -
$ helm install $GOPATH/src/github.com/yuanying/docker-gitlab/kubernetes/chart \
  --name git0 -f configs/helm/docker-gitlab.yaml \
  --namespace gitlab
```

## Update

### docker-gitlab

```bash
$ helm upgrade git0 $GOPATH/src/github.com/yuanying/docker-gitlab/kubernetes/chart \
  -f configs/helm/docker-gitlab.yaml --force
```
