#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

${OM} -k -t ${PCF_OPSMAN_FQDN} -u ${PCF_OPSMAN_ADMIN_USER} -p $PCF_OPSMAN_ADMIN_PASSWD \
  stage-product -p ${IMPORTED_NAME} -v ${IMPORTED_VERSION}
