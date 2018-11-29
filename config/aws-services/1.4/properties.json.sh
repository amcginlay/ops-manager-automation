cat <<EOF
{
  ".properties.aws_access_key_id": {
    "value": "${PCF_AWS_ACCESS_KEY_ID}"
  },
  ".properties.aws_secret_access_key": {
    "value": {
      "secret": "${PCF_AWS_SECRET_ACCESS_KEY}"
    }
  },
  ".properties.backing_db_selector": {
    "value": "Pivotal MySQL (v2)"
  },
  ".properties.backing_db_selector.p_mysql.plan_name": {
    "value": "db-small"
  },
  ".properties.backing_db_selector.p_mysql.service_instance_name": {
    "value": "aws-services"
  },
  ".properties.db_ssl_selector": {
    "type": "selector",
    "value": "Disabled"
  }
}
EOF