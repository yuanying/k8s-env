# Setup

## Working with RBAC

    $ kubectl create clusterrolebinding \
              tiller-cluster-rule \
              --clusterrole=cluster-admin \
              --serviceaccount=kube-system:default

## Setup local repository

    $ git clone https://github.com/yuanying/charts.git ~/.helm/charts


## Glusterfs

```bash
$ kubectl label node 192.168.1.124 192.168.1.125 storagenode=glusterfs
$ helm install ./charts/heketi -n gfs -f helm/heketi.yaml
```
