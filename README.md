# k8s-env
Environment files for my k8s cluster

Write config file like below:

```
---
user: core

nodes:
  172.18.201.111:
    labels:
      ingressnode: nginx
  172.18.201.112:
    labels:
      ingressnode: nginx
  172.18.201.113:
    labels:
      ingressnode: nginx
  172.18.201.121:
    gluster: true
    labels:
      storagenode: glusterfs
    devices:
    - path: /dev/vdb
      name: dev01
  172.18.201.122:
    gluster: true
    labels:
      storagenode: glusterfs
    devices:
    - path: /dev/vdb
      name: dev02
  172.18.201.123:
    gluster: true
    labels:
      storagenode: glusterfs
    devices:
    - path: /dev/vdb
      name: dev02

gluster:
  storageclass:
    slow:
      brickrootPaths: >
        172.18.201.121:/var/lib/heketi/dev01,
        172.18.201.122:/var/lib/heketi/dev02,
        172.18.201.123:/var/lib/heketi/dev03
    large:
      brickrootPaths: >
        172.18.201.121:/var/lib/heketi/dev01,
        172.18.201.122:/var/lib/heketi/dev02,
        172.18.201.123:/var/lib/heketi/dev03

gitlab:
  domain: git.lazy.work

hackmd:
  domain: hackmd.lazy.work
  github:
    client_id: "XXXXXXXXXXXXXXXXX"
    secret: "XXXXXXXXXXXXXXXXXX"

owncloud:
  domain: owncloud.lazy.work
  username: yuanying
  password: hogehoge
  email: yuan-owncloud@example.com
  mariadb:
    password: fugafugafuga

ingress:
  proxy_real_ip_cidr: "172.18.0.0/16"
  tcp:
    25: "mail/ma0-mailserver:25"
    587: "mail/ma0-mailserver:587"
    993: "mail/ma0-mailserver:993"

domains:
  fraction.jp:
    address: "192.168.1.101"
  lazy.work:
    address: "192.168.1.101"

```

And generate manifests and utility scripts from templates:

```
$ python templates/bin/render.py ${PATH_TO_CONFIG_YAML_ABOVE}
```

Now you can

-   [Setup hosts](docs/hosts.md)
-   [Install helm](docs/helm.md)
-   [Install CoreDNS](docs/coredns.md)
-   [Install GlusterFS](docs/glusterfs.md)
-   [Install Nginx Ingress Controller](docs/ingress.md)
-   [Install HackMD](docs/hackmd.md)
-   [Install ownCloud](docs/owncloud.md)
-   [Install GitLab](docs/gitlab.md)
