#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

[ -z ${IMPORTED_VERSION} ]
set $(echo ${IMPORTED_VERSION} | tr '.' ' ')
CONFIG_VERSION=${1}.${2}

[ -z ${TARGET_PLATFORM} ]

TEMPLATES=${SCRIPTDIR}/../config/director/${CONFIG_VERSION}/gcp

# WIP for om v0.45.0
#om --skip-ssl-validation \
#  configure-director \
#    --config "${TEMPLATES}/config.yml)" \
#    --vars-env PCF

om --skip-ssl-validation \
  configure-director \
    --iaas-configuration "$(source ${TEMPLATES}/iaas.json.sh)"

om --skip-ssl-validation \
  configure-director \
    --director-configuration "$(source ${TEMPLATES}/director.json.sh)"

om --skip-ssl-validation \
  configure-director \
    --az-configuration "$(source ${TEMPLATES}/azs.json.sh)"

om --skip-ssl-validation \
  configure-director \
    --networks-configuration "$(source ${TEMPLATES}/networks.${TARGET_PLATFORM}.json.sh)"

om --skip-ssl-validation \
  configure-director \
    --network-assignment "$(source ${TEMPLATES}/network_assignment.json.sh)"

om --skip-ssl-validation \
  configure-director \
    --resource-configuration "$(source ${TEMPLATES}/resources.json.sh)"

