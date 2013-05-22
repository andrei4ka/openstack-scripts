#!/bin/bash

#  Name:        04_mysql-install.sh
#  Author:      Artem Andreev
#  Email:       aandreev@mirantis.com
#  Edited by:   akirilochkin@mirantis.com
#  Date:        21.05.2013
#  Version:     0.1
#  Description: Installing and configuring Mysql script "04_mysql-install.sh" from "Openstack grizzly install package"
#


. $(dirname $(readlink -f $0))/00-lib.sh

export DEBIAN_FRONTEND=noninteractive

function configure_mysql()
{
	cp /etc/mysql/my.cnf /etc/mysql/my.cnf.openstackbackup
	sed -i "s/127.0.0.1/${mysql_host}/g" /etc/mysql/my.cnf
	mysqladmin -u root password ${mysql_password}
}

run_command "Installing MySQL server" apt-get install -y mysql-server python-mysqldb
run_command "Configure MySQL server" configure_mysql
run_command "Restarting MySQL server" service mysql restart
