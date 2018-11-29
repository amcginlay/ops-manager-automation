cat <<EOF
{
  "errands": [
    {
      "name": "smoke-tests",
      "post_deploy": false
    },
    {
      "name": "upgrade-all-service-instances",
      "post_deploy": false
    }
  ]
}
EOF