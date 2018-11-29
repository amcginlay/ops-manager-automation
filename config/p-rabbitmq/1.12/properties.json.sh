cat <<EOF
{
  ".rabbitmq-server.server_admin_credentials": {
    "value": {
      "identity": "admin",
      "password": "password"
    }
  },
  ".rabbitmq-server.rsa_certificate": {
    "value": {
      "private_key_pem": "${PCF_DOMAIN_KEY}",
      "cert_pem": "${PCF_DOMAIN_CRT}"
    }
  },
  ".properties.disk_alarm_threshold": {
    "value": "mem_relative_1_0"
  },
  ".properties.syslog_selector": {
    "value": "disabled"
  },
  ".properties.on_demand_broker_plan_1_rabbitmq_az_placement": {
    "type": "service_network_az_multi_select",
    "value": [
       "${PCF_AZ_1}"
    ]
  },
  ".properties.on_demand_broker_plan_1_disk_limit_acknowledgement": {
    "type": "multi_select_options",
    "value": [
      "acknowledge"
    ]
  },
  ".properties.on_demand_broker_plan_6_rabbitmq_az_placement": {
    "type": "service_network_az_multi_select",
    "value": [
       "${PCF_AZ_1}"
    ]
  },
  ".properties.on_demand_broker_plan_6_disk_limit_acknowledgement": {
    "type": "multi_select_options",
    "value": [
      "acknowledge"
    ]
  }
}
EOF