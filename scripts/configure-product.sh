#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

[ -z ${IMPORTED_VERSION} ]
set $(echo ${IMPORTED_VERSION} | tr '.' ' ')
CONFIG_VERSION=${1}.${2}

TEMPLATES=${SCRIPTDIR}/../config/${IMPORTED_NAME}/${CONFIG_VERSION}

if [ -z ${PCF_DOMAIN_KEY+x} ]; then
	echo "PCF_DOMAIN_KEY is not set.  Did you forget to create a certificate? (see mk-ssl-cert-key.sh)"
	exit 1
fi

om --skip-ssl-validation \
  configure-product \
    --config "${TEMPLATES}/config.yml" \
    --vars-env PCF

