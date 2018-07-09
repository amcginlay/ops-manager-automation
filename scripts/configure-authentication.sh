#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

${OM} -k -t ${PCF_OPSMAN_FQDN} \
   configure-authentication \
      --username "admin" \
      --password "${PCF_OPSMAN_ADMIN_PASSWD}" \
      --decryption-passphrase "${PCF_OPSMAN_ADMIN_PASSWD}"
