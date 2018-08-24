#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

[ -z ${IMPORTED_VERSION} ]
set $(echo ${IMPORTED_VERSION} | tr '.' ' ')
CONFIG_VERSION=${1}.${2}

TEMPLATES=${SCRIPTDIR}/../config/director/${CONFIG_VERSION}/gcp

erb -T - ${TEMPLATES}/iaas.json.erb > ${TMPDIR}/iaas.json
om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
  configure-director --iaas-configuration "$(cat ${TMPDIR}/iaas.json)"

erb -T - ${TEMPLATES}/director.json.erb > ${TMPDIR}/director.json
om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
  configure-director --director-configuration "$(cat ${TMPDIR}/director.json)"

erb -T - ${TEMPLATES}/azs.json.erb > ${TMPDIR}/azs.json
om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
   configure-director --az-configuration "$(cat ${TMPDIR}/azs.json)"

erb -T - ${TEMPLATES}/networks.json.erb > ${TMPDIR}/networks.json
om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
  configure-director --networks-configuration "$(cat ${TMPDIR}/networks.json)"

erb -T - ${TEMPLATES}/network_assignment.json.erb > ${TMPDIR}/network_assignment.json
om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
  configure-director --network-assignment "$(cat ${TMPDIR}/network_assignment.json)"

erb -T - ${TEMPLATES}/resources.json.erb > ${TMPDIR}/resources.json
om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
  configure-director --resource-configuration "$(cat ${TMPDIR}/resources.json)"
