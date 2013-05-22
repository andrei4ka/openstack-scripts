#!/bin/bash

#  Name:        14_nova-api-install.sh
#  Author:      Artem Andreev
#  Email:       aandreev@mirantis.com
#  Edited by:   akirilochkin@mirantis.com
#  Date:        22.05.2013
#  Version:     0.2
#  Description: Nova-api install script "14_nova-api-install.sh" from "Openstack grizzly install package"
#

. $(dirname $(readlink -f $0))/00-lib.sh

function configure_nova_api ()
{
	#echo "service_host = $KEYSTONE_HOST" >> /etc/nova/api-paste.ini
	#echo "service_port = 5000" >> /etc/nova/api-paste.ini
	sed -i "s/auth_host = 127.0.0.1/auth_host = ${keystone_host}/g" /etc/nova/api-paste.ini
	echo "auth_uri = http://${keystone_host}:5000/" >> /etc/nova/api-paste.ini
	sed -i "s/%SERVICE_TENANT_NAME%/${service_tenant_name}/g" /etc/nova/api-paste.ini
	sed -i "s/%SERVICE_USER%/nova/g" /etc/nova/api-paste.ini
	sed -i "s/%SERVICE_PASSWORD%/${nova_user_password}/g" /etc/nova/api-paste.ini
}

function create_database ()
{
	echo "create database nova;" > /tmp/nova.sql
	echo "grant all privileges on nova.* to nova@'%' identified by '${nova_db_password}';" >> /tmp/nova.sql
	mysql -u root -p${mysql_password} < /tmp/nova.sql
}

function restart_nova ()
{
	for svc in nova-api nova-cert nova-consoleauth nova-scheduler; do service $svc restart; done
}

#run_command "Installing Nova API" apt-get install -y nova-api nova-cert nova-consoleauth nova-scheduler nova-network nova-novncproxy nova-doc nova-conductor nova-compute-kvm
#run_command "Stop network service" service nova-network stop
#service nova-network stop > /dev/null
#run_command "Create Database" create_database
#run_command "Database Sync" nova-manage db sync
run_command "Initial network data" nova-manage network create private --fixed_range_v4=${fixed_ip_range} --num_networks=1 --bridge_interface=${data_iface_name} --vlan=${first_vlan_id} --network_size=${network_size}
run_command "Initial network data" nova-manage floating create --ip_range=${floating_ip_range} --interface=${pub_iface_name}
run_command "Configure Nova API" configure_nova_api
run_command "Restart Nova API, Cert, Consoleauth, Scheduler" restart_nova
