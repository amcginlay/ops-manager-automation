cat <<EOF
{
  ".pivotal-container-service.pks_tls": {
    "value": {
      "private_key_pem": "${PCF_DOMAIN_KEY}",
      "cert_pem": "${PCF_DOMAIN_CRT}"
    }
  },
  ".properties.pks_api_hostname": {
    "value": "api.pks.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}"
  },
  ".properties.plan1_selector.active.master_az_placement": {
    "value": [
      "us-central1-a",
      "us-central1-b",
      "us-central1-c"
    ]
  },
  ".properties.plan1_selector.active.worker_az_placement": {
    "value": [
      "us-central1-a",
      "us-central1-b",
      "us-central1-c"
    ]
  },
  ".properties.plan1_selector.active.worker_instances": {
    "value": 1
  },
  ".properties.plan2_selector": {
    "value": "Plan Inactive"
  },
  ".properties.plan3_selector": {
    "value": "Plan Inactive"
  },
  ".properties.cloud_provider": {
    "value": "GCP"
  },
  ".properties.cloud_provider.gcp.project_id": {
    "value": "${PCF_PROJECT_ID}"
  },
  ".properties.cloud_provider.gcp.network": {
    "value": "${PCF_SUBDOMAIN_NAME}-pcf-network"
  },
  ".properties.cloud_provider.gcp.master_service_account": {
    "value": "${PCF_SUBDOMAIN_NAME}-pks-master@${PCF_PROJECT_ID}.iam.gserviceaccount.com"
  },
  ".properties.cloud_provider.gcp.worker_service_account": {
    "value": "${PCF_SUBDOMAIN_NAME}-pks-worker@${PCF_PROJECT_ID}.iam.gserviceaccount.com"
  },
  ".properties.vm_extensions": {
    "value": [
      "public_ip"
    ]
  },
  ".properties.telemetry_selector": {
    "value": "disabled"
  }
}
EOF