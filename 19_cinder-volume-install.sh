#!/bin/bash

#  Name:        19_cinder-volume-install.sh
#  Author:      Artem Andreev
#  Email:       aandreev@mirantis.com
#  Edited by:   akirilochkin@mirantis.com
#  Date:        22.05.2013
#  Version:     0.2
#  Description: Cinder volume  install script "19_cinder-volume-install.sh" from "Openstack grizzly install package"
#


. $(dirname $(readlink -f $0))/00-lib.sh


function create_block_device ()
{
    dd if=/dev/zero of=$lvm_file bs=1 count=0 seek=2G
    losetup  ${lvm_block_device} ${lvm_file}
    pvcreate ${lvm_block_device}
    vgcreate ${vg_group_name} ${lvm_block_device}
}

#function configure_volume ()
#{
#    parted -s $LVM_BLOCK_DEVICE mklabel gpt
#    parted -s $LVM_BLOCK_DEVICE mkpart raid 0 100%
#    #Saving to rc.local
#}

run_command "Creating block device" create_block_device
#run_command "Configure volume" configure_volume
echo "losetup ${lvm_block_device} ${lvm_file}" >> /etc/rc.local
