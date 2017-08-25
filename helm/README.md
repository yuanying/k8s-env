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

Mount storage devices

```bash
$ fab -f fabric/fabfile.py $CLUSTER_NAME mount.parted
$ fab -f fabric/fabfile.py $CLUSTER_NAME mount.format
$ fab -f fabric/fabfile.py $CLUSTER_NAME mount
```

### Install

```bash
$ kubectl label node 192.168.1.124 192.168.1.125 storagenode=glusterfs
$ helm install ./charts/glusterfs -n gfs -f helm/glusterfs.yaml
```

### Configure the Gluster trusted pool

```bash
$ kubectl get pod --selector glusterfs-node=pod -o json | \
    jq ".items[0].metadata.name" -r | \
    xargs -I{} kubectl exec -t {} gluster peer probe 192.168.1.124
$ kubectl get pod --selector glusterfs-node=pod -o json | \
    jq ".items[0].metadata.name" -r | \
    xargs -I{} kubectl exec -t {} gluster peer probe 192.168.1.125
```

### Load StorageClass

```bash
$ kubectl create -f gluster/glusterfs-storageclass.yaml
```

## Kubernetes Dashbord

```bash
$ helm install -n ui stable/kubernetes-dashboard -f helm/dashboard.yaml
```

## Nginx-Ingress

```bash
$ kubectl label node 192.168.1.111 192.168.1.112 192.168.1.113 ingressnode=nginx
$ helm install -n ing stable/nginx-ingress -f helm/nginx-ingress.yaml
```

## kube-lego

```bash
$ helm install -n certs stable/kube-lego -f helm/kube-lego.yaml
```
