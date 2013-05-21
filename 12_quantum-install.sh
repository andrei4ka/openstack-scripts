#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function create_database ()
{
    echo "create database quantum;" > /tmp/quantum.sql
    echo "grant all privileges on quantum.* to quantum@'%' identified by '$QUANTUM_DB_PASSWORD';" >> /tmp/quantum.sql
    mysql -u root -p$MYSQL_PASSWORD < /tmp/quantum.sql
}


function configure_quantum ()
{
	#Edit the /etc/quantum/quantum.conf file:
	sed -i "s/# core_plugin =/core_plugin = quantum.plugins.linuxbridge.lb_quantum_plugin.LinuxBridgePluginV2/g" /etc/quantum/quantum.conf

	#Edit /etc/quantum/api-paste.ini
	sed -i "s/^\[filter:authtoken]/#[filter#:authtoken]/g" /etc/quantum/api-paste.ini
	sed -i "s/^paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory/#paste.filter_factory = #keystoneclient.middleware.auth_token:filter_factory/g" /etc/quantum/api-paste.ini

	echo "[filter:authtoken]" >> /etc/quantum/api-paste.ini
	echo "paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory" >> /etc/quantum/api-paste.ini
	echo "auth_host = $KEYSTONE_HOST" >> /etc/quantum/api-paste.ini
	echo "auth_port = 35357" >> /etc/quantum/api-paste.ini
	echo "auth_protocol = http" >> /etc/quantum/api-paste.ini
	echo "admin_tenant_name = $SERVICE_TENANT_NAME" >> /etc/quantum/api-paste.ini
	echo "admin_user = quantum" >> /etc/quantum/api-paste.ini
	echo "admin_password = $QUANTUM_USER_PASSWORD" >> /etc/quantum/api-paste.ini

	#Edit the LinuxBridge plugin config file /etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini with:
	# under [DATABASE] section
	sed -i "s/sql_connection =/#sql_connection =/g" /etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini
	sed -i "s/^\[DATABASE]/#[DATABASE]/g" /etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini
	sed -i "s/reconnect_interval = 2/#reconnect_interval = 2/g" /etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini

	echo "QUANTUM_PLUGIN_CONFIG=\"/etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini\"" >  /etc/default/quantum-server

	echo "[DATABASE]" >> /etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini
	echo "reconnect_interval = 2" >> /etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini
	echo "sql_connection = mysql://quantum:$QUANTUM_DB_PASSWORD@$QUANTUM_PUB_HOST/quantum" >> /etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini
	# under [LINUX_BRIDGE] section
	sed -i "s/# Default: physical_interface_mappings =/physical_interface_mappings = physnet1:$PUB_IFACE_NAME/g" /etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini
	# under [VLANS] section
	sed -i "s/^\[VLANS]/#[VLANS]/g" /etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini
	echo "[VLANS]" >> /etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini
	echo "tenant_network_type = vlan" >> /etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini
	echo "network_vlan_ranges = physnet1:1000:2999" >> /etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini
	#Edit the /etc/quantum/l3_agent.ini:
	sed -i "s/interface_driver = quantum.agent.linux.interface.OVSInterfaceDriver/interface_driver = quantum.agent.linux.interface.BridgeInterfaceDriver/g" /etc/quantum/l3_agent.ini
	#Update the /etc/quantum/quantum.conf:
	sed -i "s/auth_host = 127.0.0.1/auth_host = $KEYSTONE_HOST/g" /etc/quantum/quantum.conf
	sed -i "s/%SERVICE_TENANT_NAME%/$SERVICE_TENANT_NAME/g" /etc/quantum/quantum.conf
	sed -i "s/admin_user =/admin_user = quantum/g" /etc/quantum/quantum.conf
	sed -i "s/%SERVICE_USER%/$SERVICE_USER/g" /etc/quantum/quantum.conf
	sed -i "s/%SERVICE_PASSWORD%/$SERVICE_PASSWORD/g" /etc/quantum/quantum.conf
	sed -i "s/core_plugin = quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2/#core_plugin = quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2/g" /etc/quantum/quantum.conf

	#Edit the /etc/quantum/dhcp_agent.ini:
	sed -i "s/#interface_driver = quantum.agent.linux.interface.BridgeInterfaceDriver/interface_driver = quantum.agent.linux.interface.BridgeInterfaceDriver/g" /etc/quantum/dhcp_agent.ini
	#Update /etc/quantum/metadata_agent.ini:
	# The Quantum user information for accessing the Quantum API.
	sed -i "s/localhost/$KEYSTONE_HOST/g" /etc/quantum/metadata_agent.ini
	sed -i "s/%SERVICE_TENANT_NAME%/$SERVICE_TENANT_NAME/g" /etc/quantum/metadata_agent.ini
	sed -i "s/%SERVICE_USER%/$SERVICE_USER/g" /etc/quantum/metadata_agent.ini
	sed -i "s/%SERVICE_PASSWORD%/$SERVICE_PASSWORD/g" /etc/quantum/metadata_agent.ini
	# IP address used by Nova metadata server
	sed -i "s/# nova_metadata_ip = 127.0.0.1/nova_metadata_ip = $NOVA_HOST/g" /etc/quantum/metadata_agent.ini
	# TCP Port used by Nova metadata server
	sed -i "s/# nova_metadata_port = 8775/nova_metadata_port = 8775/g" /etc/quantum/metadata_agent.ini
	echo "metadata_proxy_shared_secret = helloOpenStack" >> /etc/quantum/metadata_agent.ini

}

function restart_quantum_services ()
{
	cd /etc/init.d/; for i in $( ls quantum-* ); do sudo service $i restart; done
	service dnsmasq restart
}

run_command "Installing Quantum and other components" apt-get install -y quantum-server quantum-plugin-linuxbridge quantum-plugin-linuxbridge-agent dnsmasq quantum-dhcp-agent quantum-l3-agent
run_command "Creating Database" create_database
run_command "Configure Quantum" configure_quantum
run_command "Restart all Quantum services" restart_quantum_services
