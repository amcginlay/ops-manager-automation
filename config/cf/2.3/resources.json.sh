cat <<EOF
{
  "router": {
    "elb_names": [
      "tcp:${PCF_SUBDOMAIN_NAME}-cf-ws",
      "http:${PCF_SUBDOMAIN_NAME}-httpslb"
    ]
  },
  "control": {
    "elb_names": [
      "tcp:${PCF_SUBDOMAIN_NAME}-cf-ssh"
    ]
  },
  "compute": {
    "instances": 3
  }
}
EOF
