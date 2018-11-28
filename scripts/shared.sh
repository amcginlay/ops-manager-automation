#!/bin/bash

set -u # explode if any env vars are not set

function printline() {
  echo && printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - && echo $1
}

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
VARS=${HOME}/.env

if ! which om > /dev/null; then
  echo "error: scripts require 'om' to be installed (https://github.com/pivotal-cf/om/releases)"
  exit 1
fi

if ! which pivnet > /dev/null; then
  echo "error: scripts require 'pivnet' to be installed (https://github.com/pivotal-cf/pivnet-cli/releases)"
  exit 1
fi

if ! which jq > /dev/null; then
  echo "error: scripts require 'jq' to be installed (https://github.com/stedolan/jq/releases)"
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
if [ -f ./${PCF_DOMAIN}.key ]; then
	export PCF_DOMAIN_KEY=$(cat ./${PCF_DOMAIN}.key | awk '{printf "%s\\n", $0}')
	#export PCF_DOMAIN_KEY=$(cat ./${PCF_DOMAIN}.key)
fi
if [ -f ./${PCF_DOMAIN}.crt ]; then
	export PCF_DOMAIN_CRT=$(cat ./${PCF_DOMAIN}.crt | awk '{printf "%s\\n", $0}')
	#export PCF_DOMAIN_CRT=$(cat ./${PCF_DOMAIN}.crt)
fi

if [ -z "${TMPDIR:-}" ]; then 
  TMPDIR=/tmp
fi
