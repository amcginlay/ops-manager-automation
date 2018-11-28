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
      "name": "pks",
      "subnets": [{
        "iaas_identifier": "${PCF_SUBDOMAIN_NAME}-pcf-network/${PCF_SUBDOMAIN_NAME}-pks-subnet/${PCF_REGION}",
        "cidr": "10.0.10.0/24",
        "reserved_ip_ranges": "10.0.10.1-10.0.10.9",
        "dns": "169.254.169.254",
        "gateway": "10.0.10.1",
        "availability_zone_names": ["${PCF_AZ_1}","${PCF_AZ_2}","${PCF_AZ_3}"]
      }]
    },
    {
      "name": "pks-services",
      "subnets": [{
        "iaas_identifier": "${PCF_SUBDOMAIN_NAME}-pcf-network/${PCF_SUBDOMAIN_NAME}-pks-services-subnet/${PCF_REGION}",
        "cidr": "10.0.11.0/24",
        "reserved_ip_ranges": "10.0.11.1-10.0.11.9",
        "dns": "169.254.169.254",
        "gateway": "10.0.11.1",
        "availability_zone_names": ["${PCF_AZ_1}","${PCF_AZ_2}","${PCF_AZ_3}"]
      }]
    }
  ]
}
