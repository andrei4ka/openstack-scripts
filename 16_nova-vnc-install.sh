#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function configure_nova_vnc ()
{

    echo "# Vnc configuration" >> /etc/nova/nova.conf
    echo "novnc_enabled=true" >> /etc/nova/nova.conf
    echo "novncproxy_base_url=http://$VNC_PUB_HOST:6080/vnc_auto.html" >> /etc/nova/nova.conf
    echo "vpvncproxy_base_url=http://$VNC_PUB_HOST:6081/console" >> /etc/nova/nova.conf
    echo "novncproxy_port=6080" >> /etc/nova/nova.conf
    echo "vncserver_proxyclient_address=$CC_NODE_CTRL_IP" >> /etc/nova/nova.conf
    #echo "vncserver_proxyclient_address=$VNC_PUB_HOST" >> /etc/nova/nova.conf
    #echo "vncserver_listen=0.0.0.0" >> /etc/nova/nova.conf
    echo "vncserver_listen=$CC_NODE_CTRL_IP" >> /etc/nova/nova.conf

}

run_command "Installing Nova VNC" apt-get install -y novnc
run_command "Configure Nova VNC" configure_nova_vnc
