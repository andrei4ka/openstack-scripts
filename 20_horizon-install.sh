#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function configure_horizon ()
{
	sed -i "s/OPENSTACK_HOST = \"127.0.0.1\"/OPENSTACK_HOST = \"${keystone_pub_host}\"/g" /etc/openstack-dashboard/local_settings.py
#	sed -i "s/try:/#try:/g" /etc/openstack-dashboard/local_settings.py
#	sed -i "s/    from ubuntu_theme import */#    from ubuntu_theme import */g" /etc/openstack-dashboard/local_settings.py
#	sed -i "s/except ImportError:/#except ImportError:/g" /etc/openstack-dashboard/local_settings.py
#	sed -i "s/    pass/#    pass/g" /etc/openstack-dashboard/local_settings.py
}

run_command "Installing Horizon" apt-get install -y openstack-dashboard memcached
run_command "Disable Ubuntu theme" dpkg --purge openstack-dashboard-ubuntu-theme

run_command "Configure Nova" configure_horizon
run_command "Restart Apache" service apache2 restart
run_command "Restart Memcached" service memcached restart
