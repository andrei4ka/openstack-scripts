#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh


function create_block_device ()
{
    dd if=/dev/zero of=$LVM_FILE bs=1 count=0 seek=2G
    losetup  $LVM_BLOCK_DEVICE $LVM_FILE
    pvcreate $LVM_BLOCK_DEVICE
    vgcreate $VOL_GROUP_NAME $LVM_BLOCK_DEVICE
}

#function configure_volume ()
#{
#    parted -s $LVM_BLOCK_DEVICE mklabel gpt
#    parted -s $LVM_BLOCK_DEVICE mkpart raid 0 100%
#    #Saving to rc.local
#}

run_command "Creating block device" create_block_device
#run_command "Configure volume" configure_volume
echo "losetup $LVM_BLOCK_DEVICE $LVM_FILE" >> /etc/rc.local
