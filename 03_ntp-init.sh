#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function update_config()
{
	cp /etc/ntp.conf /etc/ntp.conf.openstackback
	echo -e "restrict ${ctrl_range} mask ${ctrl_mask}\nbroadcast ${ctrl_broadcast}\ndisable auth\nbroadcastclient" >> /etc/ntp.conf
}

run_command "Update config" update_config
run_command "Restart NTP server" service ntp restart
