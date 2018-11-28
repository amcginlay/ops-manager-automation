cat <<EOF
{
  ".cloud_controller.system_domain": {
    "value": "sys.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}"
  },
  ".cloud_controller.apps_domain": {
    "value": "apps.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}"
  },
  ".properties.networking_poe_ssl_certs": {
    "value": [
      {
        "name": "certificate",
        "certificate": {
	  "private_key_pem": "${PCF_DOMAIN_KEY}",
	  "cert_pem": "${PCF_DOMAIN_CRT}"
        }
      }
    ]
  },
  ".properties.haproxy_forward_tls": {
    "value": "disable"
  },
  ".ha_proxy.skip_cert_verify": {
    "value": true
  },
  ".properties.security_acknowledgement": {
    "value": "X"
  },
  ".uaa.service_provider_key_credentials": {
    "value": {
      "cert_pem": "${PCF_DOMAIN_CRT}",
      "private_key_pem": "${PCF_DOMAIN_KEY}"
    }
  },
  ".properties.credhub_key_encryption_passwords": {
    "value": [
      {
        "name": "default",
        "key": { "secret": "${PCF_OPSMAN_ADMIN_PASSWD}" },
        "primary": true
      }
    ]
  },
  ".mysql_monitor.recipient_email": {
    "value": "fbloggs@gmail.com"
  }
}
EOF
