#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd -P)
source ${SCRIPTDIR}/shared.sh

PRODUCT_SLUG=$(curl \
  --fail \
  --silent \
  ${API}/products | \
    jq -r --arg PRODUCT_NAME "${PRODUCT_NAME}" '.products[] | select(.name==$PRODUCT_NAME) | .slug')

curl \
  --fail \
  --silent \
  ${API}/products/${PRODUCT_SLUG}/releases | \
    jq -r '.releases[].version'
