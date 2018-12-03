#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

PRODUCT_SLUG=$(curl \
  --fail \
  --silent \
  ${API}/products | \
    jq --raw-output --arg PRODUCT_NAME "${PRODUCT_NAME}" '.products[] | select(.name==$PRODUCT_NAME) | .slug')

RELEASE_ID=$(curl \
  --fail \
  --silent \
  ${API}/products/${PRODUCT_SLUG}/releases | \
    jq --raw-output --arg PRODUCT_VERSION "${PRODUCT_VERSION}" '.releases[] | select(.version==$PRODUCT_VERSION) | .id')

PRODUCT_FILE_ID=$(curl \
  --fail \
  --silent \
  ${API}/products/${PRODUCT_SLUG}/releases/${RELEASE_ID} | \
    jq --raw-output --arg DOWNLOAD_REGEX "${DOWNLOAD_REGEX}" '.product_files[] | select(.sha256 | length>0) | select(.name | match($DOWNLOAD_REGEX)) | .id')

TARGETDIR=${SCRIPTDIR}/../downloads/${PRODUCT_SLUG}_${PRODUCT_VERSION}_${PRODUCT_FILE_ID}
if [ ! -d ${TARGETDIR} ]; then
  mkdir -p ${TARGETDIR}
fi

if pivnet login --api-token=${PCF_PIVNET_UAA_TOKEN}; then
  pivnet download-product-files \
    --product-slug=${PRODUCT_SLUG} \
    --release-version=${PRODUCT_VERSION} \
    --product-file-id=${PRODUCT_FILE_ID} \
    --download-dir=${TARGETDIR} \
    --accept-eula

  echo "Downloaded ${PRODUCT_SLUG}_${PRODUCT_VERSION}_${PRODUCT_FILE_ID}"
  
fi
