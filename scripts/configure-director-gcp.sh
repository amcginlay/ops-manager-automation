#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

erb -T - ${TEMPLATES}/director/gcp/iaas.json.erb > ${TMPDIR}/iaas.json
${OM} -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
   configure-bosh --iaas-configuration "$(cat ${TMPDIR}/iaas.json)"

erb -T - ${TEMPLATES}/director/gcp/director.json.erb > ${TMPDIR}/director.json
${OM} -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
   configure-bosh --director-configuration "$(cat ${TMPDIR}/director.json)"

erb -T - ${TEMPLATES}/director/gcp/azs.json.erb > ${TMPDIR}/azs.json
${OM} -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
   configure-bosh --az-configuration "$(cat ${TMPDIR}/azs.json)"

erb -T - ${TEMPLATES}/director/gcp/networks.json.erb > ${TMPDIR}/networks.json
${OM} -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
   configure-bosh --networks-configuration "$(cat ${TMPDIR}/networks.json)"

erb -T - ${TEMPLATES}/director/gcp/network_assignment.json.erb > ${TMPDIR}/network_assignment.json
${OM} -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
   configure-bosh --network-assignment "$(cat ${TMPDIR}/network_assignment.json)"
