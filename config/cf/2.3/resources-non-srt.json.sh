cat <EOF
{
  "consul_server": {
    "instances": 1
  },
  "nats": {
    "instances": 1
  },
  "mysql_proxy": {
    "instances": 1
  },
  "mysql": {
    "instances": 1
  },
  "nats": {
    "instances": 1
  },
  "diego_database": {
    "instances": 1
  },
  "uaa": {
    "instances": 1
  },
  "cloud_controller": {
    "instances": 1
  },
  "router": {
    "instances": 1,
    "elb_names": [
      "tcp:<${PCF_SUBDOMAIN_NAME}-cf-ws",
      "http:${PCF_SUBDOMAIN_NAME}-httpslb"
    ]
  },
  "cloud_controller_worker": {
    "instances": 1
  },
  "diego_brain": {
    "instances": 1,
    "elb_names": [
      "tcp:${PCF_SUBDOMAIN_NAME}-cf-ssh"
    ]
  },
  "loggregator_trafficcontroller": {
    "instances": 1
  },
  "syslog_adapter": {
    "instances": 1
  },
  "syslog_scheduler": {
    "instances": 1
  },
  "doppler": {
    "instances": 1
  }
}
EOF
