cat <<EOF
{
  ".properties.plan1_selector.active.az_multi_select": {
    "value": [
      "us-central1-a",
      "us-central1-b",
      "us-central1-c"
    ]
  },
  ".properties.plan2_selector": {
      "value": "Inactive"
  },
  ".properties.plan3_selector": {
      "value": "Inactive"
  },
  ".properties.backups_selector": {
    "value": "GCS"
  },
  ".properties.backups_selector.gcs.project_id": {
    "value": "${PCF_PROJECT_ID}"
  },
  ".properties.backups_selector.gcs.bucket_name": {
    "value": "${PCF_PROJECT_ID}-mysql-backups"
  },
  ".properties.backups_selector.gcs.service_account_json": {
    "value": {
      "secret": ${PCF_SERVICE_ACCOUNT_JSON}
    }
  }
}
EOF