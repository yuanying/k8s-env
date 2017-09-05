# README

## Requirements

```bash
$ sudo apt install -y virtinst qemu-kvm
$ sudo apt install -y xorriso uuid-runtime genisoimage
```

## Node up!

```bash
$ export NODE_OS_DISTRO=ubuntu # Select your OS distribution
$ export NODE_ADDRESS_PREFIX=192.168.200 # Specify Node address prefix
$ export NODE_NETWORK_RANGE=16 # Specify Node network range
$ export NODE_GATEWAY=192.168.11.1 # Specify default gateway
$ export NODE_DNS=192.168.11.1 # Specify DNS server address
$ # Specify OS image
$ export NODE_IMAGE="/var/lib/libvirt/images/ubuntu-xenial-docker-ec2-noclouds.qcow2"
$ bash tools/node-up.sh tools/envs/master01.sh # Start master01 server
$ bash tools/node-up.sh tools/envs/worker01.sh # Start worker01 server
```

### For Ubuntu/CentOS

1.  Build docker-installed image.
    -   See [elements/docker-install/REDME.md](../elements/docker-install/README.md)
2.  Copy built image to required path.
    -   `sudo cp ubuntu-xenial-docker-ec2-noclouds.qcow2 /var/lib/libvirt/images/ubuntu-xenial-docker-ec2-noclouds.qcow2`
    -   `sudo cp centos7-docker-ec2-noclouds.qcow2 /var/lib/libvirt/images/centos7-docker-ec2-noclouds.qcow2`
