#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function create_cinderdb ()
{
	#Prepare a Mysql database for Cinder:
	echo "CREATE DATABASE cinder;" > /tmp/cinder.sql
	echo "GRANT ALL ON cinder.* TO cinder@'%' IDENTIFIED BY '$CINDER_DB_PASSWORD';" >> /tmp/cinder.sql
	mysql -u root -p$MYSQL_PASSWORD < /tmp/cinder.sql
	

}
function configure_nova ()
{
	#Enable the iscsi-target:
	sed -i 's/false/true/g' /etc/default/iscsitarget

	#Restart the services:
	service iscsitarget start
	service open-iscsi start

	sed -i "s/service_host = 127.0.0.1/service_host = $KEYSTONE_HOST/g" /etc/cinder/api-paste.ini
	sed -i "s/auth_host = 127.0.0.1/auth_host = $KEYSTONE_HOST/g" /etc/cinder/api-paste.ini
	sed -i "s/%SERVICE_TENANT_NAME%/$SERVICE_TENANT_NAME/g" /etc/cinder/api-paste.ini
	sed -i "s/%SERVICE_USER%/cinder/g" /etc/cinder/api-paste.ini
	sed -i "s/%SERVICE_PASSWORD%/$CINDER_USER_PASSWORD/g" /etc/cinder/api-paste.ini
	
	echo "sql_connection = mysql://cinder:$CINDER_DB_PASSWORD@$MYSQL_HOST/cinder" >> /etc/cinder/cinder.conf
	sed -i "s/tgtadm/ietadm/g" /etc/cinder/cinder.conf 
	sed -i "s/^volume_group = cinder-volumes/volume_group = $VOL_GROUP_NAME/g" >> /etc/cinder/cinder.conf
	echo "# Cinder #" >> /etc/nova/nova.conf
	echo "volume_api_class=nova.volume.cinder.API" >> /etc/nova/nova.conf
#	echo "osapi_volume_listen_port=5900" >> /etc/nova/nova.conf

}

run_command "Installing Cinder" apt-get install -y cinder-api cinder-scheduler cinder-volume iscsitarget open-iscsi iscsitarget-dkms
run_command "Configure Cinder" configure_nova
run_command "Creating Cinder" create_cinderdb
run_command "Database Sync" cinder-manage db sync
run_command "Restart Cinder volume" service cinder-volume restart
run_command "Restart Cinder API" service cinder-api restart