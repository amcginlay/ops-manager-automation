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

# if product/stemcell directory does not exist in downloads, make it happen
if [ ! -d "${TARGETDIR}" ]; then
  export PRODUCT_NAME DOWNLOAD_NAME PRODUCT_VERSION
  ${SCRIPTDIR}/download-product.sh
fi 

# just cycle contents of the target directory because we don't know the name of the file
for FILENAME in $(ls ${TARGETDIR}); do
  OM_CMD="upload-product -p"
  if [[ "${PRODUCT_SLUG}" == stemcells* ]] ; then
    OM_CMD="upload-stemcell -f -s"
  fi
  
  om --skip-ssl-validation \
    ${OM_CMD} ${TARGETDIR}/${FILENAME}

  echo "Imported ${PRODUCT_SLUG}_${PRODUCT_VERSION}_${PRODUCT_FILE_ID}/${FILENAME}"

done
