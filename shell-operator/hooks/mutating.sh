#!/usr/bin/env bash

source /shell_lib.sh

function __config__(){
    cat <<EOF
configVersion: v1
kubernetesMutating:
- name: add-dynatrace-annotiation-deployments.gutek.pl
  namespace:
    labelSelector:
      matchLabels:
        # helm adds a 'name' label to a namespace it creates
        name: annotiation-mutating
  rules:
  - apiGroups:   ["apps"]
    apiVersions: ["v1"]
    operations:  ["CREATE", "UPDATE"]
    resources:   ["deployments"]
    scope:       "Namespaced"
- name: add-dynatrace-annotiation-services.gutek.pl
  namespace:
    labelSelector:
      matchLabels:
        # helm adds a 'name' label to a namespace it creates
        name: annotiation-mutating
  rules:
  - apiGroups:   [""]
    apiVersions: ["v1"]
    operations:  ["CREATE", "UPDATE"]
    resources:   ["services"]
    scope:       "Namespaced"
EOF
}

function __main__() {

  local name=$(context::jq -r '.review.request.object.metadata.name')

  # we want to apply annotiation only to specific set of deployments/services
  if [[ $name != nginx* ]]; then
    cat <<EOF > $VALIDATING_RESPONSE_PATH
{"allowed":true, "message":"Name does not match" }
EOF
      return 0
  fi

  local P=$(context::jq -r '.review.request.object.spec.template.metadata.annotations | with_entries(select(.key | startswith("prometheus")))')
  local D=$(context::jq -r '.review.request.object.spec.template.metadata.annotations | with_entries(select(.key | startswith("dynatrace")))')

  # we only want to add dynatrace if its not already there
  if [ $(jq '. | length' <<< "$D") -gt 0 ]; then
    cat <<EOF > $VALIDATING_RESPONSE_PATH
{"allowed":true, "message":"Dynatrace exists" }
EOF
      return 0
  fi

  local path=$(echo $P | jq -r '."prometheus.io/path"')
  local schema=$(echo $P | jq -r '."prometheus.io/scheme"')
  local scrape=$(echo $P | jq -r '."prometheus.io/scrape"')
  local port=$(echo $P | jq -r '."prometheus.io/port"')

  local secure=$(if [[ $schema == "https" ]]; then echo "true"; else echo "false"; fi)

  # we only want to add the annotation if it's not null/empty
  if [[ ! -z "$schema" ]] || [[ ! -z "$path" ]] || [[ ! -z "$scrape" ]] || [[ ! -z "$port" ]]; then
    local DYNATRACE_TEMPLATE=$(cat <<EOF
[{"op": "add", "path": "/spec/template/metadata/annotations/metrics.dynatrace.com~1path", "value": "$path"},
{"op": "add", "path": "/spec/template/metadata/annotations/metrics.dynatrace.com~1port", "value": "$port"},
{"op": "add", "path": "/spec/template/metadata/annotations/metrics.dynatrace.com~1secure", "value": "$secure"},
{"op": "add", "path": "/spec/template/metadata/annotations/metrics.dynatrace.com~1scrape", "value": "$scrape"}]
EOF
)
      PP=$( echo $DYNATRACE_TEMPLATE | base64 -w 0)
      cat <<EOF > $VALIDATING_RESPONSE_PATH
{"allowed":true, "patch": "$PP"}
EOF
  fi
}

hook::run $@