# README

## Requirements

```bash
$ sudo apt install -y virtinst
$ sudo apt install -y xorriso
```

## Node up!

```bash
$ export NODE_OS_DISTRO=ubuntu # Select your OS distribution
$ export NODE_ADDRESS_PREFIX=192.168.200 # Specify Node address prefix
$ export NODE_NETWORK_RANGE=16 # Specify Node network range
$ export NODE_GATEWAY=192.168.11.1 # Specify default gateway
$ export NODE_DNS=192.168.11.1 # Specify DNS server address
$ bash tools/node-up.sh tools/envs/master01.sh # Start master01 server
$ bash tools/node-up.sh tools/envs/worker01.sh # Start worker01 server
```
