#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function configure_rabit ()
{
	echo RABBITMQ_NODE_IP_ADDRESS=${rabbit_host} > /etc/rabbitmq/rabbitmq.conf.d/bind-address
	rabbitmqctl set_permissions -p / guest ".*" ".*" ".*"
}

run_command "Installing RabbitMQ server" apt-get install -y rabbitmq-server
run_command "Configure RabbitMQ server" configure_rabit
run_command "Restarting RabbitMQ server" service rabbitmq-server restart

