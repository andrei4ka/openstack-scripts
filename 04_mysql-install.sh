#!/bin/bash

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
