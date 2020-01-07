#!/bin/sh
# UBIFS atomic update on a system with two volumes for kernel (active and backup)
# Limitations: implementation relies that this script is running on a RW partition
# with enough space to store active UBIFS volume kernel image into a file for
# further writing to the kernel backup volume.

usage() {
    echo "atomic_update.sh <path/to/kernel>"
}

clean_up() {
    rm -f ${KERNEL_BACKUP} 
}

KERNEL_BACKUP="zImageBackup"

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

KERNEL_IMAGE="$1"

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

KERNEL_IMAGE="$1"

if [[ ! -e ${KERNEL_IMAGE} ]]; then
    echo "File [${KERNEL_IMAGE}] does not exist"
    exit 2
fi

echo "Copy current kernel image into file..."
cat /dev/ubi0_2 > ${KERNEL_BACKUP}

if [[ $? -ne 0 ]]; then
    echo "Current kernel image copy failed"
    exit 3
fi

echo "Done"
echo "Copy current kernel image into backup volume..."
ubiupdatevol /dev/ubi0_3 ${KERNEL_BACKUP}

if [[ $? -ne 0 ]]; then
    echo "Unable to copy current backup image"
    clean_up
    exit 4
fi

echo "Done"
clean_up
echo "Copy new ${KERNEL_IMAGE} into current kernel volume..."
ubiupdatevol /dev/ubi0_2 ${KERNEL_IMAGE}

if [[ $? -ne 0 ]]; then
    echo "Unable to update kernel"
    exit 5
fi

echo "Done"
reboot
