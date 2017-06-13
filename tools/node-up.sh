#!/usr/bin/env bash

set -eu
export LC_ALL=C

NODE_UUID=${NODE_UUID:-$(uuidgen)}
NODE_HOSTNAME=${NODE_HOSTNAME:-$1}
NODE_CPU=${NODE_CPU:-'2'}
NODE_MEMORY=${NODE_MEMORY:-'2048'}
NODE_DISK=${NODE_DISK:-'40'}
NODE_ADDITIONAL_DISKS=${NODE_ADDITIONAL_DISKS:-'10'}
NODE_NETWORK_HOST_BRIDGE=${NODE_NETWORK_HOST_BRIDGE:-'br0'}
NODE_IMAGE=${NODE_IMAGE:-'/var/lib/libvirt/images/ubuntu-xenial-docker-ec2-noclouds.qcow2'}
NODE_USERDATA=${NODE_USERDATA:-'~/cloud.yaml'}


LIBVIRT_PATH=${LIBVIRT_PATH:-'/var/lib/libvirt/images'}
if [ ! -d ${LIBVIRT_PATH} ]; then
    sudo mkdir -p ${LIBVIRT_PATH} || (echo "Can not create ${LIBVIRT_PATH} directory" && exit 1)
fi


echo "Setup USERDATA: ${NODE_HOSTNAME} node..."

USERDATA_DIR_PATH=${LIBVIRT_PATH}/${NODE_HOSTNAME}/openstack/latest
if [ ! -d ${USERDATA_DIR_PATH} ]; then
    sudo mkdir -p ${USERDATA_DIR_PATH} || (echo "Can not create ${USERDATA_DIR_PATH} directory" && exit 1)
fi
sudo cp ${NODE_USERDATA} ${USERDATA_DIR_PATH}/user_data
sudo cat <<EOF | sudo tee ${USERDATA_DIR_PATH}/meta_data.json
{
    "uuid": "${NODE_UUID}"
}
EOF
USERDATA_DISK="--filesystem ${LIBVIRT_PATH}/$NODE_HOSTNAME/,config-2,type=mount,mode=squash"


echo "Creating: ${NODE_HOSTNAME} node..."

if [ ! -f ${LIBVIRT_PATH}/${NODE_HOSTNAME}.qcow2 ]; then
    sudo cp ${NODE_IMAGE} ${LIBVIRT_PATH}/${NODE_HOSTNAME}.qcow2
    sudo qemu-img resize ${LIBVIRT_PATH}/${NODE_HOSTNAME}.qcow2 ${NODE_DISK}G
fi
dev_index='b'
additional_disk=''
additional_disk_params=''
for disk_size in ${NODE_ADDITIONAL_DISKS}; do
    additional_disk=${LIBVIRT_PATH}/${NODE_HOSTNAME}-vd${dev_index}.img
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
             --disk path=${LIBVIRT_PATH}/${NODE_HOSTNAME}.qcow2,format=qcow2,bus=virtio \
             ${additional_disk_params} \
             ${USERDATA_DISK} \
             --vnc \
             --noautoconsole
