#!/bin/bash

#  Name:        06_netutils-install.sh
#  Author:      Artem Andreev
#  Email:       aandreev@mirantis.com
#  Edited by:   akirilochkin@mirantis.com
#  Date:        21.05.2013
#  Version:     0.1
#  Description: Configuring sysctl script from "Openstack grizzly install package"
#

. $(dirname $(readlink -f $0))/00-lib.sh

function update_config()
{
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
}

run_command "Installing  vlan && brigde utils" apt-get install -y vlan bridge-utils
run_command "Updating sysctl config" update_config
run_command "Applying sysctl" sysctl net.ipv4.ip_forward=1

