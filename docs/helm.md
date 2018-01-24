# Helm

## Install

```bash
$ curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
```

## Working with RBAC

```bash
$ kubectl create clusterrolebinding \
          tiller-cluster-rule \
          --clusterrole=cluster-admin \
          --serviceaccount=kube-system:default
$ helm init # TODO use `--service-account`
```
