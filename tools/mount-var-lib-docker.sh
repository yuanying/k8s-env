#!/usr/bin/env bash

# systemctl stop docker
# rm -rf /var/lib/docker
# mkdir -p /var/lib/docker

set -eu
export LC_ALL=C

DEVICE=${1}

parted ${DEVICE} mklabel gpt
# parted ${DEVICE} -s mkpart untitled xfs 0G 100% -s p

mkfs.xfs -i size=512 ${DEVICE} -L docker-data -f

cat <<EOF > /etc/systemd/system/var-lib-docker.mount
[Unit]
Description=Mount /dev/disk/by-label/docker-data
[Mount]
What=/dev/disk/by-label/docker-data
Where=/var/lib/docker
Type=xfs
Options=defaults,noatime,uquota,gquota,pquota
[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/var-lib-docker.automount
[Unit]
Description=Automount /dev/disk/by-label/docker-data
[Automount]
Where=/var/lib/docker
[Install]
WantedBy=multi-user.target
WantedBy=docker.service
EOF

systemctl enable var-lib-docker.mount
systemctl enable var-lib-docker.automount

systemctl start var-lib-docker.automount

# systemctl start docker
# systemctl start kubelet