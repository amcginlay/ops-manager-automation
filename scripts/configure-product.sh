#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

if [ -z ${PCF_DOMAIN_KEY+x} ]; then
	echo "PCF_DOMAIN_KEY is not set.  Did you forget to create a certificate? (see mk-ssl-cert-key.sh)"
	exit 1
fi

PRODUCT_GUID=$(
  ${OM} -k -t ${PCF_OPSMAN_FQDN} -u ${PCF_OPSMAN_ADMIN_USER} -p ${PCF_OPSMAN_ADMIN_PASSWD} \
    curl --silent \
      --path "/api/v0/staged/products" | ${JQ} -r '.[] | select(.type == "'${IMPORTED_NAME}'") | .guid'
)

erb -T - ${TEMPLATES}/${IMPORTED_NAME}/network.json.erb > ${TMPDIR}/network.json
erb -T - ${TEMPLATES}/${IMPORTED_NAME}/properties.json.erb > ${TMPDIR}/properties.json
erb -T - ${TEMPLATES}/${IMPORTED_NAME}/resources.json.erb > ${TMPDIR}/resources.json
[ -s ${TEMPLATES}/${IMPORTED_NAME}/errands.json.erb ]  && \
  erb -T - ${TEMPLATES}/${IMPORTED_NAME}/errands.json.erb > ${TMPDIR}/errands.json

# some products need network configured in isolation so configure in two steps
${OM} -k -t "${PCF_OPSMAN_FQDN}" -u "${PCF_OPSMAN_ADMIN_USER}" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
  configure-product \
    --product-name "${IMPORTED_NAME}" \
    --product-network "$(cat ${TMPDIR}/network.json)"

${OM} -k -t "${PCF_OPSMAN_FQDN}" -u "${PCF_OPSMAN_ADMIN_USER}" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
  configure-product \
    --product-name "${IMPORTED_NAME}" \
    --product-properties "$(cat ${TMPDIR}/properties.json)" \
    --product-resources "$(cat ${TMPDIR}/resources.json)"

# if file present, configure errands (via Om curl)
if [ -s ${TEMPLATES}/${IMPORTED_NAME}/errands.json.erb ]; then
  ${OM} -k -t "${PCF_OPSMAN_FQDN}" -u "${PCF_OPSMAN_ADMIN_USER}" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
    curl --silent \
      --path /api/v0/staged/products/${PRODUCT_GUID}/errands \
      --request "PUT" \
      --data "$(cat ${TMPDIR}/errands.json)"
fi
