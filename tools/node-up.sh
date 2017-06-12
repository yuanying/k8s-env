#!/usr/bin/env bash

set -eu
export LC_ALL=C

HOST=${HOST:-$1}
CPU=${CPU:-'2'}
MEMORY=${MEMORY:-'2048'}
DISK=${DISK:-'40'}
ADDITIONAL_DISKS=${ADDITIONAL_DISKS:-'10'}
NETWORK_BRIDGE=${NETWORK_BRIDGE:-'br0'}
LIBVIRT_PATH=${LIBVIRT_PATH:-'/var/lib/libvirt/images'}
IMAGE=${IMAGE:-'/var/lib/libvirt/images/ubuntu-xenial-docker-ec2-noclouds.qcow2'}
USERDATA=${USERDATA:-'~/cloud.yaml'}

if [ ! -d ${LIBVIRT_PATH} ]; then
    sudo mkdir -p ${LIBVIRT_PATH} || (echo "Can not create ${LIBVIRT_PATH} directory" && exit 1)
fi


echo "Setup USERDATA: ${HOST} node..."

USERDATA_DIR_PATH=${LIBVIRT_PATH}/${HOST}/openstack/latest
if [ ! -d ${USERDATA_DIR_PATH} ]; then
    sudo mkdir -p ${USERDATA_DIR_PATH} || (echo "Can not create ${USERDATA_DIR_PATH} directory" && exit 1)
fi
sudo cp ${USERDATA} ${USERDATA_DIR_PATH}/user_data
USERDATA_DISK="--filesystem ${LIBVIRT_PATH}/$HOST/,config-2,type=mount,mode=squash"


echo "Creating: ${HOST} node..."

if [ ! -f ${LIBVIRT_PATH}/${HOST}.qcow2 ]; then
    sudo cp ${IMAGE} ${LIBVIRT_PATH}/${HOST}.qcow2
    sudo qemu-img resize ${LIBVIRT_PATH}/${HOST}.qcow2 ${DISK}G
fi
dev_index='b'
additional_disk=''
additional_disk_params=''
for disk_size in ${ADDITIONAL_DISKS}; do
    additional_disk=${LIBVIRT_PATH}/${HOST}-vd${dev_index}.img
    if [ ! -f ${additional_disk} ]; then
        sudo qemu-img create ${additional_disk} ${disk_size}G
    fi
    additional_disk_params=${additional_disk_params}" --disk path=${additional_disk},format=raw,bus=virtio"
    dev_index=$(echo "${dev_index}" | tr "0-9a-z" "1-9a-z_")
done

sudo virt-install --connect qemu:///system \
             --import \
             --name ${HOST} \
             --ram ${MEMORY} \
             --vcpus ${CPUS} \
             --network bridge=${NETWORK_BRIDGE} \
             --os-type=linux \
             --os-variant=virtio26 \
             --disk path=${LIBVIRT_PATH}/${HOST}.qcow2,format=qcow2,bus=virtio \
             ${additional_disk_params} \
             ${USERDATA_DISK} \
             --vnc \
             --noautoconsole
