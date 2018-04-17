#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

TARGETDIR=${SCRIPTDIR}/../downloads/${PRODUCT_SLUG}_${PRODUCT_VERSION}_${PRODUCT_FILE_ID}

# if product/stemcell directory does not exist in downloads, make it happen
if [ ! -d ${TARGETDIR} ]; then
	eval PRODUCT_SLUG=${PRODUCT_SLUG} PRODUCT_VERSION=${PRODUCT_VERSION} PRODUCT_FILE_ID=${PRODUCT_FILE_ID} \
	  ${SCRIPTDIR}/download-product.sh
fi 

# just cycle contents of the target directory because we don't know the name of the file
for FILENAME in $(ls ${TARGETDIR}); do
  OM_CMD="upload-product -p"
  if [ "${PRODUCT_SLUG}" == "stemcells" ] ; then
    OM_CMD="upload-stemcell -f -s"
  fi
  
  ${OM} -k -t ${PCF_OPSMAN_FQDN} -u ${PCF_OPSMAN_ADMIN_USER} -p ${PCF_OPSMAN_ADMIN_PASSWD} \
    ${OM_CMD} ${TARGETDIR}/${FILENAME}

  echo "Imported ${PRODUCT_SLUG}_${PRODUCT_VERSION}_${PRODUCT_FILE_ID}/${FILENAME}"

done
