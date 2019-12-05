#!/bin/bash
# (c) Copyright 2018 SUSE LLC
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#

# parameters:
# $1 - venv directory for the openstack service whose policy is being generated, must
# contain bin/oslopolicy-policy-generator or script will fail
# $2 - user account that has read access to the service config directory
# $3 - namespace
# $4 - config-dir for the service
# $5 - Horizon venv directory (file will be written to /openstack_dashboard/conf under here)
# $6 - user account that will be the owner of the generated policy configuration file
# $7 - file format (yaml or json)
servicevenv=$1
serviceuser=$2
namespace=$3
configdir=$4
horizonvenv=$5
horizonuser=$6
format=${7:-json}

set -e

policy_cfg=$(sudo -u ${serviceuser} ${servicevenv}/bin/oslopolicy-policy-generator --namespace ${namespace} --config-dir ${configdir})

if [[ $format == json ]]; then
    policy_cfg=$(python -c 'import sys, yaml, json; print json.dumps(yaml.load(sys.stdin.read()))' <<< "$policy_cfg" | python -m json.tool)
fi

cat <<< "$policy_cfg" | su - ${horizonuser} -s /bin/sh -c "cat > ${horizonvenv}/openstack_dashboard/conf/${namespace}_policy.${format}"
