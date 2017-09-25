#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`

target_dir=${1:-"${script_dir}/images"}
NODE_PUBKEY_PATH=${NODE_PUBKEY_PATH:-"~/.ssh/id_rsa.pub"}
NODE_PUBLIC_KEY=${NODE_PUBLIC_KEY:-"auto"}
if [[ ${NODE_PUBLIC_KEY} == "auto" ]]; then
    export NODE_PUBLIC_KEY=`cat ${NODE_PUBKEY_PATH}`
fi

CHANNEL=stable
RELEASE=current
ORG_IMG_NAME="coreos_${CHANNEL}_${RELEASE}_image.img"
ORG_IMG_FULLPATH=${target_dir}/${ORG_IMG_NAME}
IMG_NAME="coreos_${CHANNEL}_${RELEASE}_image-$(date +"%Y%m%d-%H%M%S").img"
IMG_FULLPATH=${target_dir}/${IMG_NAME}

if [ ! -d ${target_dir} ]; then
  mkdir -p ${target_dir} || (echo "Can not create ${target_dir} directory" && exit 1)
fi

if [ ! -f ${ORG_IMG_FULLPATH} ]; then
  wget https://${CHANNEL}.release.core-os.net/amd64-usr/${RELEASE}/coreos_production_image.bin.bz2 -O - | bzcat > ${ORG_IMG_FULLPATH} || (rm -f ${ORG_IMG_FULLPATH} && echo "Failed to download image" && exit 1)
fi

rootfs=${target_dir}/rootfs-${IMG_NAME}
mkdir -p ${rootfs}

echo "===================================="
echo "Creating ${IMG_FULLPATH}"

cp ${ORG_IMG_FULLPATH} ${IMG_FULLPATH}

loop_device=$(losetup -f)
device_basename=$(basename $loop_device)
losetup ${loop_device} ${IMG_FULLPATH}
kpartx -av ${loop_device}
# The ROOT partition should be #9 so make assumptions here...
# If I can, using label is better...
mount /dev/mapper/${device_basename}p9 ${rootfs}

echo "---> Copying userdata..."
cat <<EOF > ${rootfs}/var/lib/coreos-install/user_data
#cloud-config
---
hostname: coreos-install
ssh_authorized_keys:
- ${NODE_PUBLIC_KEY}
EOF

umount ${rootfs}
kpartx -dv ${loop_device}
losetup -d ${loop_device}

echo "Created: ${IMG_FULLPATH}"
