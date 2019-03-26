#!/bin/sh

if [ -z ${HOSTNAME+x} ]; then
  HOSTNAME=$(hostname -s)
fi

if [ -d /run/secrets/kubernetes.io/serviceaccount ]; then
  METADATA_NAMESPACE=$(cat /run/secrets/kubernetes.io/serviceaccount/namespace)
  BEARER_TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)
  STATEFULSET_NAME="${HOSTNAME%-*}"
  POD_ORDINAL="${HOSTNAME##*-}"
  JSONFILE="$(mktemp)"
  curl -s -o "$JSONFILE" \
    --cacert "/run/secrets/kubernetes.io/serviceaccount/ca.crt" \
    --header "Authorization: Bearer $BEARER_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT/apis/apps/v1/namespaces/$METADATA_NAMESPACE/statefulsets/$STATEFULSET_NAME"
  if [ "$(jq -r .kind $JSONFILE)" = "StatefulSet" ]; then
    SPEC_REPLICAS="$(jq .spec.replicas $JSONFILE)"
    if [ "$POD_ORDINAL" -ge "$SPEC_REPLICAS" ]; then
      while ! nodetool decommission; do
        if nodetool netstats | grep -i Mode | grep -i DRAINED; then
          exec nodetool stopdaemon
        fi
        sleep 60
      done
    fi
  fi
fi

exec nodetool drain
