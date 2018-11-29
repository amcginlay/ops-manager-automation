cat <<EOF
{
  "singleton_availability_zone": {
    "name": "${PCF_AZ_1}"
  },
  "other_availability_zones": [
    {
      "name": "${PCF_AZ_1}"
    },
    {
      "name": "${PCF_AZ_2}"
    },
    {
      "name": "${PCF_AZ_3}"
    }
  ],
  "network": {
    "name": "pas"
  },
  "service_network": {
    "name": "services"
  }
}
EOF