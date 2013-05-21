#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function configure_nova_compute ()
{
	echo "# Metadata" >> /etc/nova/nova.conf
	echo "service_quantum_metadata_proxy = True" >> /etc/nova/nova.conf
	echo "quantum_metadata_proxy_shared_secret = helloOpenStack" >> /etc/nova/nova.conf

	echo "# Network settings" >> /etc/nova/nova.conf
	echo "network_api_class=nova.network.quantumv2.api.API" >> /etc/nova/nova.conf
	echo "quantum_url=http://$QUANTUM_PUB_HOST:9696" >> /etc/nova/nova.conf
	echo "quantum_auth_strategy=keystone" >> /etc/nova/nova.conf
	echo "quantum_admin_tenant_name=$SERVICE_TENANT_NAME" >> /etc/nova/nova.conf
	echo "quantum_admin_username=quantum" >> /etc/nova/nova.conf
	echo "quantum_admin_password=$QUANTUM_USER_PASSWORD" >> /etc/nova/nova.conf
	echo "quantum_admin_auth_url=http://$QUANTUM_PUB_HOST:35357/v2.0" >> /etc/nova/nova.conf
	echo "libvirt_vif_driver=nova.virt.libvirt.vif.QuantumLinuxBridgeVIFDriver" >> /etc/nova/nova.conf
	echo "linuxnet_interface_driver=nova.network.linux_net.LinuxBridgeInterfaceDriver" >> /etc/nova/nova.conf
	echo "firewall_driver=nova.virt.libvirt.firewall.IptablesFirewallDriver" >> /etc/nova/nova.conf
	echo "# Compute #" >> /etc/nova/nova.conf
	echo "compute_driver=libvirt.LibvirtDriver" >> /etc/nova/nova.conf
	echo "# Cinder #" >> /etc/nova/nova.conf
	echo "volume_api_class=nova.volume.cinder.API" >> /etc/nova/nova.conf
	echo "osapi_volume_listen_port=5900" >> /etc/nova/nova.conf
	#Edit the /etc/nova/nova-compute.conf:
	echo "libvirt_vif_type=ethernet" >> /etc/nova/nova-compute.conf
	echo "libvirt_vif_driver=nova.virt.libvirt.vif.QuantumLinuxBridgeVIFDriver" >> /etc/nova/nova-compute.conf

}

function restart_nova ()
{
    cd /etc/init.d/; for i in $( ls nova-* ); do sudo service $i restart; done
}


run_command "Installing Nova" apt-get install -y nova-compute nova-network
run_command "Configure Nova Compute and Network" configure_nova_compute
run_command "Restart All Nova Services" restart_nova
