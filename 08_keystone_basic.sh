#!/bin/bash

#  Name:        08_keystone_basic.sh
#  Author:      Artem Andreev
#  Email:       aandreev@mirantis.com
#  Edited by:   akirilochkin@mirantis.com
#  Date:        22.05.2013
#  Version:     0.2
#  Description: Keystone basic config script "08_keystone_basic.sh" from "Openstack grizzly install package"
#


#If you running this script standalone, next line will be commented.
. $(dirname $(readlink -f $0))/00-lib.sh

admin_password=${admin_password:-admin_pass}
service_password=${service_password:-service_pass}

export SERVICE_TOKEN=${admin_token}
export SERVICE_ENDPOINT="http://${cc_host}:35357/v2.0"

service_tenant_name=${service_tenant_name:-service}


# Tenants
admin_tenant_id=$(get_id keystone tenant-create --name=admin)
service_tenant_id=$(get_id keystone tenant-create --name=$service_tenant_name)


# Users
admin_user_id=$(get_id keystone user-create --name=admin --pass="${admin_password}" --email=admin@domain.com)


# Roles
admin_role_id=$(get_id keystone role-create --name=admin)
keystoneadmin_role_id=$(get_id keystone role-create --name=KeystoneAdmin)
keystoneservice_role_id=$(get_id keystone role-create --name=KeystoneServiceAdmin)

# Add Roles to Users in Tenants
keystone user-role-add --user-id $ADMIN_USER --role-id ${admin_role_id} --tenant-id ${admin_tenant_id}
keystone user-role-add --user-id $ADMIN_USER --role-id ${keystoneadmin_role_id} --tenant-id ${admin_tenant_id}
keystone user-role-add --user-id $ADMIN_USER --role-id ${keystoneservice_role_id} --tenant-id ${admin_tenant_id}

# The Member role is used by Horizon and Swift
member_role_id=$(get_id keystone role-create --name=Member)

# Configure service users/roles
nova_user_id=$(get_id keystone user-create --name=nova --pass="${service_password}" --tenant-id ${service_tenant_id} --email=nova@domain.com)
keystone user-role-add --tenant-id ${service_tenant_id} --user-id ${nova_user_id} --role-id ${admin_role_id}

glance_user_id=$(get_id keystone user-create --name=glance --pass="$SERVICE_PASSWORD" --tenant-id ${service_tenant_id} --email=glance@domain.com)
keystone user-role-add --tenant-id ${service_tenant_id} --user-id ${glance_user_id} --role-id ${admin_role_id}

quantum_user_id=$(get_id keystone user-create --name=quantum --pass="$SERVICE_PASSWORD" --tenant-id ${service_tenant_id} --email=quantum@domain.com)
keystone user-role-add --tenant-id ${service_tenant_id} --user-id ${quantum_user_id} --role-id ${admin_role_id}

cinder_user_id=$(get_id keystone user-create --name=cinder --pass="$SERVICE_PASSWORD" --tenant-id ${service_tenant_id} --email=cinder@domain.com)
keystone user-role-add --tenant-id ${service_tenant_id} --user-id ${cinder_user_id} --role-id ${admin_role_id}
