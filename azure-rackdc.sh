#!/bin/bash

set -euo pipefail
: "${AZURE_API_VERSION:=2019-06-04}"

MetadataAPI() {
  curl \
    --connect-timeout 5 \
    --fail \
    --header "Metadata:true" \
    --silent \
    "http://169.254.169.254/metadata/$1?api-version=$AZURE_API_VERSION&format=text"
}

InstanceAPI() {
  MetadataAPI "instance/compute/$1"
}

location=$(InstanceAPI "location")
zone=$(InstanceAPI "zone")
# update_domain=$(InstanceAPI "platformUpdateDomain")
# fault_domain=$(InstanceAPI "platformFaultDomain")

case "$1" in
  dc)
    echo "$location"
    ;;
  rack)
    if [ -n "$zone" ]; then
      echo "$location-$zone"
    else
      echo "$location"
    fi
    ;;
esac
