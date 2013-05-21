#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function update_config()
{
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
}

run_command "Installing  vlan && brigde utils" apt-get install -y vlan bridge-utils
run_command "Updating sysctl config" update_config
run_command "Applying sysctl" sysctl net.ipv4.ip_forward=1

