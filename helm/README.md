# Setup

## Working with RBAC

    $ kubectl create clusterrolebinding \
              tiller-cluster-rule \
              --clusterrole=cluster-admin \
              --serviceaccount=kube-system:default

## Setup local repository

    $ git clone https://github.com/yuanying/charts.git ~/.helm/charts


## Glusterfs

### Prerequsite

Enable dm_* modules

```bash
$ fab -f fabric/fabfile.py $CLUSTER_NAME device_mapper.enable
```

### Install

```bash
$ kubectl label node 192.168.1.124 192.168.1.125 storagenode=glusterfs
$ helm install ./charts/heketi -n gfs -f helm/heketi.yaml
$ export HEKETI_CLI_SERVER=http://$(kubectl get svc gfs-heketi -o json | jq -r '.["spec"]["clusterIP"]'):8080
$ heketi-cli topology load --json=gluster/topology.json
```

### Load StorageClass

```bash
$ export HEKETI_ADDRESS=$(kubectl get svc gfs-heketi -o json | jq -r '.["spec"]["clusterIP"]')
$ sed s/__HEKETI_ADDRESS__/${HEKETI_ADDRESS}/ gluster/glusterfs-storageclass.yaml.in \
  | kubectl create -f -
```
