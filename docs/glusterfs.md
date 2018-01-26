# GlusterFS

## Install

### Namespace

```bash
$ kubectl apply -f manifests/namespaces/glusterfs.yaml
$ kubectl config set-context cluster --namespace storage
```

### Mount storage devices

```bash
$ fab -f fabric/fabfile.py cluster mount.format
$ fab -f fabric/fabfile.py cluster mount
```

### Deploy glusterfs

```bash
$ bash bin/gluster-label-storage-node.sh
$ helm install ./charts/glusterfs -n gfs \
  -f helm/glusterfs.yaml \
  --namespace storage
```

### Configure the Gluster trusted pool

```bash
$ bash bin/gluster-configure-trusted-pool.sh
```

### Create storage class

```bash
$ kubectl apply -f configs/manifests/glusterfs-storageclass.yaml
```

## Update

### Upgrade glusterfs

```bash
$ helm upgrade gfs ./charts/glusterfs -f helm/glusterfs.yaml --recreate-pods
```
