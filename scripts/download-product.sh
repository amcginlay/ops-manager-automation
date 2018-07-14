#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

PRODUCT_SLUG=$(curl \
  --fail \
  --silent \
  ${API}/products | \
    jq -r --arg PRODUCT_NAME "${PRODUCT_NAME}" '.products[] | select(.name==$PRODUCT_NAME) | .slug')

RELEASE_ID=$(curl \
  --fail \
  --silent \
  ${API}/products/${PRODUCT_SLUG}/releases | \
    jq -r --arg PRODUCT_VERSION "${PRODUCT_VERSION}" '.releases[] | select(.version==$PRODUCT_VERSION) | .id')

PRODUCT_FILE_ID=$(curl \
  --fail \
  --silent \
  ${API}/products/${PRODUCT_SLUG}/releases/${RELEASE_ID} | \
    jq -r --arg DOWNLOAD_NAME "${DOWNLOAD_NAME}" '.product_files[] | select(.name | contains($DOWNLOAD_NAME)) | .id')

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
