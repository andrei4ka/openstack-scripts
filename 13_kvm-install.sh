#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function configure_KVM ()
{
	echo "cgroup_device_acl = [" >> /etc/libvirt/qemu.conf
	echo "\"/dev/null\", \"/dev/full\", \"/dev/zero\"," >> /etc/libvirt/qemu.conf
	echo "\"/dev/random\", \"/dev/urandom\"," >> /etc/libvirt/qemu.conf
	echo "\"/dev/ptmx\", \"/dev/kvm\", \"/dev/kqemu\"," >> /etc/libvirt/qemu.conf
	echo "\"/dev/rtc\", \"/dev/hpet\",\"/dev/net/tun\" ]" >> /etc/libvirt/qemu.conf

	#Enable live migration by updating /etc/libvirt/libvirtd.conf file:
	sed -i "s/#listen_tls = 0/listen_tls = 0/g" /etc/libvirt/libvirtd.conf
	sed -i "s/#listen_tcp = 1/listen_tcp = 1/g" /etc/libvirt/libvirtd.conf
	sed -i "s/#auth_tcp = \"sasl\"/auth_tcp = \"none\"/g" /etc/libvirt/libvirtd.conf
	#Edit libvirtd_opts variable in /etc/init/libvirt-bin.conf file:
	sed -i "s/^env libvirtd_opts=\"-d\"/env libvirtd_opts=\"-d -l\"/g" /etc/init/libvirt-bin.conf
	#Edit /etc/default/libvirt-bin file
	sed -i "s/^libvirtd_opts=\"-d\"/libvirtd_opts=\"-d -l\"/g" /etc/default/libvirt-bin

}
function delete_def_bridge ()
{
	#Delete default virtual bridge
	virsh net-destroy default
	virsh net-undefine default
}


run_command "Installing KVM packages" apt-get install -y kvm libvirt-bin pm-utils
run_command "Configure KVM" configure_KVM
run_command "Delete default virtual bridge" delete_def_bridge
run_command "Restart the libvirt service to load the new values" service libvirt-bin restart
