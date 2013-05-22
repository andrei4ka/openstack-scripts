#!/bin/bash

#  Name:        10_glance-install.sh
#  Author:      Artem Andreev
#  Email:       aandreev@mirantis.com
#  Edited by:   akirilochkin@mirantis.com
#  Date:        22.05.2013
#  Version:     0.2
#  Description: Glance install script "10_glance-install.sh" from "Openstack grizzly install package"
#

. $(dirname $(readlink -f $0))/00-lib.sh

function configure_glance()
{
	echo "service_host = ${keystone_host}" >> /etc/glance/glance-api-paste.ini
	echo "service_port = 5000" >> /etc/glance/glance-api-paste.ini
	echo "auth_host = ${keystone_host}" >> /etc/glance/glance-api-paste.ini
	echo "auth_port = 35357" >> /etc/glance/glance-api-paste.ini
	echo "auth_protocol = http" >> /etc/glance/glance-api-paste.ini
	echo "auth_uri = http://${keystone_host}:5000/" >> /etc/glance/glance-api-paste.ini
	echo "admin_tenant_name = ${service_tenant_name}" >> /etc/glance/glance-api-paste.ini
	echo "admin_user = glance" >> /etc/glance/glance-api-paste.ini
	echo "admin_password = ${glance_user_password}" >> /etc/glance/glance-api-paste.ini

	sed -i 's/#flavor=/flavor = keystone/g' /etc/glance/glance-api.conf
	sed -i "s%sql_connection = sqlite:////var/lib/glance/glance.sqlite%sql_connection = mysql://glance:${glance_db_password}@${mysql_host}/glance%g" /etc/glance/glance-api.conf

	echo "service_host = ${keystone_host}" >> /etc/glance/glance-registry-paste.ini
	echo "service_port = 5000" >> /etc/glance/glance-registry-paste.ini
	echo "auth_host = ${keystone_host}" >> /etc/glance/glance-registry-paste.ini
	echo "auth_port = 35357" >> /etc/glance/glance-registry-paste.ini
	echo "auth_protocol = http" >> /etc/glance/glance-registry-paste.ini
	echo "auth_uri = http://${keystone_host}:5000/" >> /etc/glance/glance-registry-paste.ini
	echo "admin_tenant_name = ${service_tenant_name}" >> /etc/glance/glance-registry-paste.ini
	echo "admin_user = glance" >> /etc/glance/glance-registry-paste.ini
	echo "admin_password = ${glance_user_password}" >> /etc/glance/glance-registry-paste.ini

	sed -i "s%sql_connection = sqlite:////var/lib/glance/glance.sqlite%sql_connection = mysql://glance:${glance_db_password}@${mysql_host}/glance%g" /etc/glance/glance-registry.conf
	sed -i 's/#flavor=/flavor = keystone/g' /etc/glance/glance-registry.conf
	
	echo "create database glance;" > /tmp/glance.sql
	echo "grant all privileges on glance.* to glance@'%' identified by '${glance_db_password}';" >> /tmp/glance.sql
	mysql -u root -p${mysql_password} < /tmp/glance.sql
	glance-manage db_sync
}

run_command "Installing Glance" apt-get install -y glance
run_command "Configure Glance" configure_glance
run_command "Restarting Glance API" service glance-api restart
run_command "Restarting Glance Registry" service glance-registry restart
