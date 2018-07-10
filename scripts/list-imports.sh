#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

${OM} -k -t "${PCF_OPSMAN_FQDN}" -u "admin" -p "${PCF_OPSMAN_ADMIN_PASSWD}" \
   available-products
