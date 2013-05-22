#!/bin/bash

#  Name:        11_glance-init.sh
#  Author:      Artem Andreev
#  Email:       aandreev@mirantis.com
#  Edited by:   akirilochkin@mirantis.com
#  Date:        22.05.2013
#  Version:     0.2
#  Description: Glance init script "11_glance-init.sh " from "Openstack grizzly install package"
#

. $(dirname $(readlink -f $0))/00-lib.sh
. $(dirname $(readlink -f $0))/creds

function init_glance ()
{
	mkdir /tmp/image
	PWD=$(pwd)
	#cd /tmp/image
	#wget -c http://uec-images.ubuntu.com/releases/precise/release/ubuntu-12.04-server-cloudimg-amd64.tar.gz
	#tar xzvf ubuntu-12.04-server-cloudimg-amd64.tar.gz
	#export OS_TENANT_NAME=admin
	#export OS_USERNAME=admin
	#export OS_PASSWORD=$ADMIN_PASSWORD
	#export OS_AUTH_URL="http://$KEYSTONE_HOST:5000/v2.0/"
	#glance add name="Ubuntu" is_public=true container_format=ovf disk_format=qcow2 < precise-server-cloudimg-amd64.img
	glance image-create --name myFirstImage --is-public true --container-format bare --disk-format qcow2 --location https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img
	cd $PWD
}

run_command "Init Glance" init_glance
