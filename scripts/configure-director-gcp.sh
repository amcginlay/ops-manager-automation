#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

[ -z ${IMPORTED_VERSION} ]
set $(echo ${IMPORTED_VERSION} | tr '.' ' ')
CONFIG_VERSION=${1}.${2}

[ -z ${TARGET_PLATFORM} ]

TEMPLATES=${SCRIPTDIR}/../config/director/${CONFIG_VERSION}/gcp

om --skip-ssl-validation \
  configure-director \
    --config "${TEMPLATES}/config-${TARGET_PLATFORM}.yml" \
    --vars-env PCF

