#!/bin/bash

#  Name:        15_nova-common-install.sh
#  Author:      Artem Andreev
#  Email:       aandreev@mirantis.com
#  Edited by:   akirilochkin@mirantis.com
#  Date:        22.05.2013
#  Version:     0.2
#  Description: Quantum install script "15_nova-common-install.sh" from "Openstack grizzly install package"
#


. $(dirname $(readlink -f $0))/00-lib.sh

function configure_nova ()
{
	cp /etc/nova/nova.conf /etc/nova/nova.conf.openstackbackup
	echo "[DEFAULT]" > /etc/nova/nova.conf
	echo "logdir=/var/log/nova" >> /etc/nova/nova.conf
	echo "state_path=/var/lib/nova" >> /etc/nova/nova.conf
	echo "lock_path=/run/lock/nova" >> /etc/nova/nova.conf
	echo "verbose=True" >> /etc/nova/nova.conf
	echo "api_paste_config=/etc/nova/api-paste.ini" >> /etc/nova/nova.conf
	echo "compute_scheduler_driver=nova.scheduler.simple.SimpleScheduler" >> /etc/nova/nova.conf
	echo "rabbit_host=${rabbit_host}" >> /etc/nova/nova.conf
	echo "nova_url=http://${nova_pub_host}:8774/v1.1/" >> /etc/nova/nova.conf
	echo "sql_connection=mysql://nova:${nova_db_password}@${mysql_host}/nova" >> /etc/nova/nova.conf
	echo "root_helper=sudo nova-rootwrap /etc/nova/rootwrap.conf" >> /etc/nova/nova.conf
	echo "# Auth"
	echo "use_deprecated_auth=false" >> /etc/nova/nova.conf
	echo "auth_strategy=keystone" >> /etc/nova/nova.conf
	echo "# Imaging service" >> /etc/nova/nova.conf
	echo "glance_api_servers=${glance_host}:9292" >> /etc/nova/nova.conf
	echo "glance_host=${glance_host}" >> /etc/nova/nova.conf
	echo "image_service=nova.image.glance.GlanceImageService" >> /etc/nova/nova.conf
}

run_command "Installing Nova" apt-get install -y nova-common
run_command "Configure Nova" configure_nova
