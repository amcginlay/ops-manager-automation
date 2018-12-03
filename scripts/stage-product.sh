#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

om --skip-ssl-validation \
  stage-product \
    -p ${IMPORTED_NAME} -v ${IMPORTED_VERSION}
