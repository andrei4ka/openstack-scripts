#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function configure_keystone()
{
	tmp_keystone_sql_file=/tmp/keystone.db.sql
	keystone_config=/etc/keystone/keystone.conf

	sed -i "s/# admin_token = ADMIN/admin_token = ${admin_token}/g" ${keystone_config}
	sed -i "s%connection = sqlite:////var/lib/keystone/keystone.db%connection = mysql://keystone:${keystone_db_password}@${mysql_host}/keystone%g" ${keystone_config}
	echo "create database keystone;" > ${tmp_keystone_sql_file}
	echo "grant all privileges on keystone.* to keystone@'%' identified by '$keystone_db_password';" >> ${tmp_keystone_sql_file}
	mysql -uroot -p${mysql_password} < ${tmp_keystone_sql_file}

}

run_command "Installing Keystone" apt-get install -y keystone
run_command "Configure Keystone" configure_keystone
run_command "Restart Keystone" service keystone restart
run_command "Sync db Keystone" keystone-manage db_sync

