#!/bin/bash

#  Name:        02_ntp-install.sh
#  Author:      Artem Andreev
#  Email:       aandreev@mirantis.com
#  Edited by:   akirilochkin@mirantis.com
#  Date:        21.05.2013
#  Version:     0.1
#  Description: Install of NTP server "02_ntp-install.sh" from "Openstack grizzly install package"
#

. $(dirname $(readlink -f $0))/00-lib.sh

run_command "Installing NTP server" apt-get install -y ntp
