#!/bin/bash

set -euo pipefail
: "${AWS_API_VERSION:=latest}"

MetadataAPI() {
  curl \
    --connect-timeout 5 \
    --fail \
    --silent \
    "http://169.254.169.254/$AWS_API_VERSION/meta-data/$1"
}

zone=$(MetadataAPI "placement/availability-zone")
region="${zone%-*}"

case "$1" in
  dc)
    echo "$region"
    ;;
  rack)
    echo "$zone"
    ;;
esac
