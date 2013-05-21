#
#  Author:      Artem Andreev
#  Email:       aandreev@mirantis.com
#  Edited by:   akirilochkin@mirantis.com
#  Date:        21.05.2013
#  Version:     0.1
#  Description: Base function script from "Openstack grizzly install package"
#


base_dir=$(dirname $(readlink -f $0))
config=${base_dir}/stackrc
local_config=localrc

admin_password=${admin_password:-admin_password}
service_password=${service_password:-service_pass}
service_tenant_name=${service_tenant_name:-service}


function read_config()
{
	. ${config}
	if test -e ${local_config}; then
		echo "using local configuration file ${local_config}" >&2
		. ${local_config}
	fi
}

function run_command()
{
	echo -n "$1..."
        shift
        STDOUT=$($* 2>&1) && (echo "DONE") || (echo "ERROR"; echo $STDOUT; kill -9 $$)
}

get_id () {
    echo `$@ | awk '/ id / { print $4 }'`
}


read_config
