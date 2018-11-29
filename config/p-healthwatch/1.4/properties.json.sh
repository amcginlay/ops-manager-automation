cat <<EOF
{
  ".properties.opsman": {
    "value": "enable"
  },
  ".properties.opsman.enable.url": {
    "value": "https://pcf.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}"
  },
  ".healthwatch-forwarder.health_check_az": {
    "value": "${PCF_AZ_1}"
  },
  ".properties.boshtasks": {
    "value": "disable"
  }
}
EOF