#!/bin/bash

set -u # explode if any env vars are not set

function printline() {
  echo && printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - && echo $1
}

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
VARS=${HOME}/.env

if ! which erb > /dev/null; then
	echo "Embedded Ruby (erb) not installed on host machine.  (https://www.ruby-lang.org/en/documentation/installation)"
	exit 1
fi

if [ ! -f ${VARS} ]; then
	echo "Please create a valid ~/.env by executing ./scripts/create-env.sh and customizing to suit your target environment"
	exit 1
fi

while read LINE; do
  [[ ! -z ${LINE} ]] && eval export ${LINE}
done < ${VARS}

export API="https://network.pivotal.io/api/v2"
export PCF_SERVICE_ACCOUNT_JSON=$(cat ${SCRIPTDIR}/../gcp_credentials.json)
export PCF_PROJECT_ID=$(gcloud config get-value core/project)

# calculated vars
export PCF_DOMAIN=${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
export TEMPLATES=${SCRIPTDIR}/../config/${PCF_VERSION_PATH}/templates
if [ -f ./${PCF_DOMAIN}.key ]; then
	export PCF_DOMAIN_KEY=$(cat ./${PCF_DOMAIN}.key)
fi
if [ -f ./${PCF_DOMAIN}.crt ]; then
	export PCF_DOMAIN_CRT=$(cat ./${PCF_DOMAIN}.crt)
fi

# for platform independence
OM_BIN=om-linux
PIVNET_BIN=pivnet-linux
JQ_BIN=jq-linux
if [ "$(uname -s)" == "Darwin" ]; then
  OM_BIN=om-darwin
  PIVNET_BIN=pivnet-darwin
  JQ_BIN=jq-darwin
fi
OM=${SCRIPTDIR}/../bin/${OM_BIN}
PIVNET=${SCRIPTDIR}/../bin/${PIVNET_BIN}
JQ=${SCRIPTDIR}/../bin/${JQ_BIN}

if [ -z "${TMPDIR:-}" ]; then 
  TMPDIR=/tmp
fi
