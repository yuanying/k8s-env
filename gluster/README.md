
## Prerequsite

Enable dm_* modules

```bash
$ fab -f fabric/fabfile.py $CLUSTER_NAME device_mapper.enable
```

## Setup storage class

```bash
$ HEKETI_ADDRESS=$(kubectl get svc gfs-heketi -o json | jq -r '.["spec"]["clusterIP"]')
$ sed s/__HEKETI_ADDRESS__/${HEKETI_ADDRESS}/ gluster/glusterfs-storageclass.yaml.in \
  | kubectl create -f -
```
