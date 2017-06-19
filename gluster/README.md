
## Prerequsite

Enable dm_* modules

```bash
$ fab -f fabric/fabfile.py $CLUSTER_NAME device_mapper.enable
```

## Install heketi/gluster via gluster-kubernetes

```bash
$ git clone https://github.com/gluster/gluster-kubernetes.git
$ cd gluster-kubernetes/deploy
$ # TODO Modify topology.json
$ ./gk-deploy -g -v ./topology.json
```

## Setup storage class

```bash
$ HEKETI_CLI_SERVER=$(kubectl get svc heketi -o json | jq -r '.["spec"]["clusterIP"]')
$ echo 'apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: slow
provisioner: kubernetes.io/glusterfs
parameters:
  resturl: "http://${HEKETI_CLI_SERVER}:8080"
  volumetype: "replicate:2"' | kubectl create -f -
```
