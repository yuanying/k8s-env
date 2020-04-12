#!/usr/bin/env bash

set -eu
export LC_ALL=C

NODE_ENV=${1:-""}
script_dir=$(dirname "${BASH_SOURCE}")

if [[ ${NODE_ENV} != '' ]]; then
    source ${NODE_ENV}
fi

export NODE_UUID=${NODE_UUID:-$(uuidgen)}
export NODE_HOSTNAME=${NODE_HOSTNAME:-$1}
export NODE_CPU=${NODE_CPU:-'2'}
export NODE_MEMORY=${NODE_MEMORY:-'2048'}
export NODE_DISK=${NODE_DISK:-'40'}
export NODE_ADDITIONAL_DISKS=${NODE_ADDITIONAL_DISKS:-''}
export NODE_NETWORK_HOST_BRIDGE=${NODE_NETWORK_HOST_BRIDGE:-'br0'}
export NODE_IMAGE=${NODE_IMAGE:-"${NODE_ROOT}/ubuntu-xenial-docker-ec2-noclouds.qcow2"}
export NODE_USERDATA=${NODE_USERDATA:-'~/cloud.yaml'}
export NODE_OS_DISTRO=${NODE_OS_DISTRO:-'ubuntu'}
export NODE_HOSTNAME=${NODE_HOSTNAME:-'master'}
export NODE_ADDRESS=${NODE_ADDRESS:-'192.168.203.11'}

if [[ ${NODE_ENV} != '' ]]; then
    echo "Generate userdata: ${NODE_USERDATA}"
    bash ${script_dir}/generate-userdata.sh > ${NODE_USERDATA}
fi


if [ ! -d ${NODE_ROOT} ]; then
    sudo mkdir -p ${NODE_ROOT} || (echo "Can not create ${NODE_ROOT} directory" && exit 1)
fi


echo "Setup USERDATA: ${NODE_HOSTNAME} node..."

USERDATA_DIR_PATH=${NODE_ROOT}/${NODE_HOSTNAME}/nocloud
CONFIG_DRIVE_PATH=${NODE_ROOT}/${NODE_HOSTNAME}.iso
if [ ! -d ${USERDATA_DIR_PATH} ]; then
    sudo mkdir -p ${USERDATA_DIR_PATH} || (echo "Can not create ${USERDATA_DIR_PATH} directory" && exit 1)
fi
sudo cp ${NODE_USERDATA} ${USERDATA_DIR_PATH}/user-data
sudo cat <<EOF | sudo tee ${USERDATA_DIR_PATH}/meta-data
instance_id: "${NODE_UUID}"
local-hostname: "${NODE_HOSTNAME}"
EOF
sudo cat <<EOF | sudo tee ${USERDATA_DIR_PATH}/network-config
version: 2
ethernets:
  ${NODE_NET_DEVICE}:
    dhcp4: no
    dhcp6: no
    addresses: [${NODE_ADDRESS}/${NODE_NETWORK_RANGE}]
    gateway4: ${NODE_GATEWAY}
    nameservers:
      addresses: ["${NODE_DNS}"]
EOF
# sudo mkisofs -R -V config-2 -o ${CONFIG_DRIVE_PATH} ${NODE_ROOT}/${NODE_HOSTNAME}
sudo genisoimage -output ${CONFIG_DRIVE_PATH} -volid cidata -joliet -rock \
    ${USERDATA_DIR_PATH}/user-data \
    ${USERDATA_DIR_PATH}/meta-data \
    ${USERDATA_DIR_PATH}/network-config
USERDATA_DISK="--disk ${CONFIG_DRIVE_PATH},device=cdrom,perms=ro"

echo "Creating: ${NODE_HOSTNAME} node..."

if [ ! -f ${NODE_ROOT}/${NODE_HOSTNAME}.qcow2 ]; then
    sudo cp ${NODE_IMAGE} ${NODE_ROOT}/${NODE_HOSTNAME}.qcow2
    sudo qemu-img resize ${NODE_ROOT}/${NODE_HOSTNAME}.qcow2 ${NODE_DISK}G
fi
dev_index='b'
additional_disk=''
additional_disk_params=''
for disk_size in ${NODE_ADDITIONAL_DISKS}; do
    additional_disk=${NODE_ROOT}/${NODE_HOSTNAME}-vd${dev_index}.img
    if [ ! -f ${additional_disk} ]; then
        sudo qemu-img create ${additional_disk} ${disk_size}G
    fi
    additional_disk_params=${additional_disk_params}" --disk path=${additional_disk},format=raw,bus=virtio"
    dev_index=$(echo "${dev_index}" | tr "0-9a-z" "1-9a-z_")
done

sudo virt-install --connect qemu:///system \
             --import \
             --name ${NODE_HOSTNAME} \
             --ram ${NODE_MEMORY} \
             --vcpus ${NODE_CPU} \
             --network bridge=${NODE_NETWORK_HOST_BRIDGE} \
             --os-type=linux \
             --os-variant=virtio26 \
             --disk path=${NODE_ROOT}/${NODE_HOSTNAME}.qcow2,format=qcow2,bus=virtio \
             ${additional_disk_params} \
             ${USERDATA_DISK} \
             --vnc \
             --noautoconsole
