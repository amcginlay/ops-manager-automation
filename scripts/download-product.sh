#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

TARGETDIR=${SCRIPTDIR}/../downloads/${PRODUCT_SLUG}_${PRODUCT_VERSION}_${PRODUCT_FILE_ID}
if [ ! -d ${TARGETDIR} ]; then
  mkdir -p ${TARGETDIR}
fi

if ${PIVNET} login --api-token=${PCF_PIVNET_UAA_TOKEN}; then
  ${PIVNET} download-product-files \
    -p ${PRODUCT_SLUG} \
    -r ${PRODUCT_VERSION} \
    -i ${PRODUCT_FILE_ID} \
    --download-dir=${TARGETDIR} \
    --accept-eula

  echo "Downloaded ${PRODUCT_SLUG}_${PRODUCT_VERSION}_${PRODUCT_FILE_ID}"
  
fi
