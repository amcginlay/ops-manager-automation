cat <<EOF
{
  "pivotal-container-service": {
    "elb_names": [
      "tcp:${PCF_SUBDOMAIN_NAME}-pks-api"
    ]
  }
}
EOF