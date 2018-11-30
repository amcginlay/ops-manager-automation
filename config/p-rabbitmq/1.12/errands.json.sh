cat <<EOF
{
  "errands": [
    {
      "name": "on-demand-broker-smoke-tests",
      "post_deploy": false
    },
    {
      "name": "upgrade-all-service-instances",
      "post_deploy": false
    }
  ]
}
EOF