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

PRODUCT_GUID=$(
  om -k -t ${PCF_OPSMAN_FQDN} -u "admin" -p ${PCF_OPSMAN_ADMIN_PASSWD} \
    curl --silent \
      --path "/api/v0/staged/products" | \
        jq -r '.[] | select(.type == "'${IMPORTED_NAME}'") | .guid'
)

erb -T - ${TEMPLATES}/network.json.erb > ${TMPDIR}/network.json
erb -T - ${TEMPLATES}/properties.json.erb > ${TMPDIR}/properties.json
erb -T - ${TEMPLATES}/resources.json.erb > ${TMPDIR}/resources.json
[ -s ${TEMPLATES}/errands.json.erb ]  && \
  erb -T - ${TEMPLATES}/errands.json.erb > ${TMPDIR}/errands.json

# some products need network configured in isolation so configure in two steps
om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
  configure-product \
    --product-name "${IMPORTED_NAME}" \
    --product-network "$(cat ${TMPDIR}/network.json)"

om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
  configure-product \
    --product-name "${IMPORTED_NAME}" \
    --product-properties "$(cat ${TMPDIR}/properties.json)" \
    --product-resources "$(cat ${TMPDIR}/resources.json)"

# if file present, configure errands (via Om curl)
if [ -s ${TEMPLATES}/${IMPORTED_NAME}/errands.json.erb ]; then
  om -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
    curl --silent \
      --path /api/v0/staged/products/${PRODUCT_GUID}/errands \
      --request "PUT" \
      --data "$(cat ${TMPDIR}/errands.json)"
fi
