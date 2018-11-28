#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

[ -z ${IMPORTED_VERSION} ]
set $(echo ${IMPORTED_VERSION} | tr '.' ' ')
CONFIG_VERSION=${1}.${2}

[ -z ${TARGET_PLATFORM} ]

TEMPLATES=${SCRIPTDIR}/../config/director/${CONFIG_VERSION}/gcp

om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
  configure-director --iaas-configuration "$(source ${TEMPLATES}/iaas.json.sh)"

om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
  configure-director --director-configuration "$(source ${TEMPLATES}/director.json.sh)"

om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
   configure-director --az-configuration "$(source ${TEMPLATES}/azs.json.sh)"

om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
  configure-director --networks-configuration "$(source ${TEMPLATES}/networks.${TARGET_PLATFORM}.json.sh)"

om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
  configure-director --network-assignment "$(source ${TEMPLATES}/network_assignment.json.sh)"

om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
  configure-director --resource-configuration "$(source ${TEMPLATES}/resources.json.sh)"
