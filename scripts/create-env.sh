#!/bin/bash

if [ -f ${HOME}/.env ]; then
  echo "${HOME}/.env already exists. Please remove this file first."
  exit
fi

cat > ${HOME}/.env <<-EOF
PCF_VERSION_PATH=2.1                                  # maps to a product config path in this ops-manager-automation github repo
PCF_PIVNET_UAA_TOKEN=CHANGE_ME_PCF_PIVNET_UAA_TOKEN   # see https://network.pivotal.io/users/dashboard/edit-profile
PCF_DOMAIN_NAME=CHANGE_ME_DOMAIN_NAME                 # e.g. pivotaledu.io
PCF_SUBDOMAIN_NAME=CHANGE_ME_SUBDOMAIN_NAME           # e.g. cls99env66
PCF_OPSMAN_ADMIN_PASSWD=CHANGE_ME_OPSMAN_ADMIN_PASSWD # e.g. for simplicity, recycle your PCF_PIVNET_UAA_TOKEN 
PCF_REGION=CHANGE_ME_REGION                           # e.g. us-central1	
PCF_AZ_1=CHANGE_ME_AZ_1                               # e.g. us-central1-a	
PCF_AZ_2=CHANGE_ME_AZ_2                               # e.g. us-central1-b	
PCF_AZ_3=CHANGE_ME_AZ_3                               # e.g. us-central1-c	

PCF_OPSMAN_FQDN=pcf.\${PCF_SUBDOMAIN_NAME}.\${PCF_DOMAIN_NAME}
EOF

echo "Created template version of '${HOME}/.env'. Please customize to suit your target environment before continuing."
