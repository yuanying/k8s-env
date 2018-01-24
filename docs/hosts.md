# Setup hosts

```bash
$ ln -s $GOPATH/src/github.com/yuanying/k8s-env/configs/cluster.yaml \
        $GOPATH/src/github.com/yuanying/k8s-env/fabric/configs/cluster.yaml
```

## Setup HAproxy

```bash
$ sudo bash configs/docker/haproxy.sh
```
