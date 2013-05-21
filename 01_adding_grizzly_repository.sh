#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function add_repository() {
	apt-get install ubuntu-cloud-keyring python-software-properties software-properties-common python-keyring
	echo deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/grizzly main >> /etc/apt/sources.list.d/grizzly.list
}

run_command "Adding the official grizzly repositories" add_repository
run_command "Update Ubuntu" apt-get update
run_command "Upgrade Ubuntu" apt-get upgrade -y
run_command "Distupgrade Ubuntu" apt-get dist-upgrade -y
