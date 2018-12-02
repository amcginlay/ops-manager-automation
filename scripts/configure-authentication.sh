#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

om -k configure-authentication \
  --decryption-passphrase "${OM_DECRYPTION_PASSPHRASE}"
