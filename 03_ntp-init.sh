#!/bin/bash

#  Name:        03_ntp-init.sh
#  Author:      Artem Andreev
#  Email:       aandreev@mirantis.com
#  Edited by:   akirilochkin@mirantis.com
#  Date:        21.05.2013
#  Version:     0.1
#  Description: Configuring NTP server script "03_ntp-init.sh" from "Openstack grizzly install package"
#

. $(dirname $(readlink -f $0))/00-lib.sh

function update_config()
{
    cp /etc/ntp.conf /etc/ntp.conf.openstackback
    echo -e "restrict ${ctrl_range} mask ${ctrl_mask}\nbroadcast ${ctrl_broadcast}\ndisable auth\nbroadcastclient" >> /etc/ntp.conf
}

run_command "Update config" update_config
run_command "Restart NTP server" service ntp restart
