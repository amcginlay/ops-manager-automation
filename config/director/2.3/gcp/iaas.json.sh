cat <<EOF
{
  "project": "${PCF_PROJECT_ID}",
  "associated_service_account": "${PCF_SUBDOMAIN_NAME}-opsman@${PCF_PROJECT_ID}.iam.gserviceaccount.com",
  "default_deployment_tag": "${PCF_SUBDOMAIN_NAME}"
}
EOF
