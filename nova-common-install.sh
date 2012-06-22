#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install -y nova-common

NOVA_CONFIG=/etc/nova/nova.conf

backup_file $NOVA_CONFIG

cat >>$NOVA_CONFIG <<NOVA_CONFIG
# NOTE: the configuration below was appended by installation script
--dhcpbridge_flagfile=/etc/nova/nova.conf
--dhcpbridge=/usr/bin/nova-dhcpbridge
--logdir=/var/log/nova
--state_path=/var/lib/nova
--lock_path=/var/lock/nova
--force_dhcp_release
--iscsi_helper=tgtadm
--libvirt_use_virtio_for_bridges
--connection_type=libvirt
--root_helper=sudo nova-rootwrap
--verbose
--ec2_private_dns_show_ip
--sql_connection=mysql://nova:$MYSQL_PASSWORD@$MYSQL_HOST/nova
--rabbit_host=$RABBITMQ_IP
--auth_strategy=keystone
--glance_api_servers=$GLANCE_HOST:9292
--glance_host=$GLANCE_HOST
NOVA_CONFIG
