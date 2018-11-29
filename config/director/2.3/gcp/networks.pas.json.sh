cat <<EOF
{
  "icmp_checks_enabled": false,
  "networks": [
    {
      "name": "infrastructure",
      "subnets": [{
        "iaas_identifier": "${PCF_SUBDOMAIN_NAME}-pcf-network/${PCF_SUBDOMAIN_NAME}-infrastructure-subnet/${PCF_REGION}",
        "cidr": "10.0.0.0/26",
        "reserved_ip_ranges": "10.0.0.1-10.0.0.9",
        "dns": "169.254.169.254",
        "gateway": "10.0.0.1",
        "availability_zone_names": ["${PCF_AZ_1}","${PCF_AZ_2}","${PCF_AZ_3}"]
      }]
    },
    {
      "name": "pas",
      "subnets": [{
        "iaas_identifier": "${PCF_SUBDOMAIN_NAME}-pcf-network/${PCF_SUBDOMAIN_NAME}-pas-subnet/${PCF_REGION}",
        "cidr": "10.0.4.0/24",
        "reserved_ip_ranges": "10.0.4.1-10.0.4.9",
        "dns": "169.254.169.254",
        "gateway": "10.0.4.1",
        "availability_zone_names": ["${PCF_AZ_1}","${PCF_AZ_2}","${PCF_AZ_3}"]
      }]
    },
    {
      "name": "services",
      "subnets": [{
        "iaas_identifier": "${PCF_SUBDOMAIN_NAME}-pcf-network/${PCF_SUBDOMAIN_NAME}-services-subnet/${PCF_REGION}",
        "cidr": "10.0.8.0/24",
        "reserved_ip_ranges": "10.0.8.1-10.0.8.9",
        "dns": "169.254.169.254",
        "gateway": "10.0.8.1",
        "availability_zone_names": ["${PCF_AZ_1}","${PCF_AZ_2}","${PCF_AZ_3}"]
      }]
    }
  ]
}
EOF
