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
# $2 - namespace
# $3 - config-dir for the service
# $4 - Horizon venv directory (file will be written to /openstack_dashboard/conf under here)
servicevenv=$1
namespace=$2
configdir=$3
horizonvenv=$4

${servicevenv}/bin/oslopolicy-policy-generator --namespace ${namespace} --config-dir ${configdir} | python -c 'import sys, yaml, json; y=yaml.load(sys.stdin.read()); print json.dumps(y)' | python -m json.tool > ${horizonvenv}/openstack_dashboard/conf/${namespace}_policy.json
