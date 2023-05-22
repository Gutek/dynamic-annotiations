
# working command
# kubectl patch deployment nginx1-deployment  --type "json" -p '[{"op": "add", "path": "/spec/template/metadata/annotations/metrics.dynatrace.com~1path", "value": "PATH"}, {"op": "add", "path": "/spec/template/metadata/annotations/metrics.dynatrace.com~1port", "value": "8080"}]'

function f {

    local name=$(cat test.json | jq -r '.metadata.name')

    # we want to apply annotiation only to specific set of deployments/services
    if [[ $name != nginx* ]]; then
        echo $name
        return 0
    fi

    local P=$(cat test.json | jq -r '.spec.template.metadata.annotations | with_entries(select(.key | startswith("prometheus")))')
    local D=$(cat test.json | jq -r '.spec.template.metadata.annotations | with_entries(select(.key | startswith("dynatrace")))')



    # we only want to add dynatrace if its not already there
    if [ $(jq '. | length' <<< "$D") -gt 0 ]; then
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

        echo '['$DYNATRACE_TEMPLATE']' | base64
        
        T=$(echo '['$DYNATRACE_TEMPLATE']' | base64)
        T=${T//$'\n'/}
        #echo $T
        #echo -n '['$DYNATRACE_TEMPLATE']' | base64
    fi





}

f

# | map(if .key == "prometheus.io/path" then {"metrics.dynatrace.com/path": .value} else empty end)'



#echo $PA
# {
#   "prometheus.io/path": "/metrics",
#   "prometheus.io/schema": "https",
#   "nothing": true
# }

#   local annotations=$(context::jq -r '.review.request.objectk .spec.template.metadata.annotations')
#   local prometheus=$(cat my.json | jq -r 'to_entries[] | select(.key | startswith("prometheus"))')
#   local dynatrace=$(cat my.json | jq -r 'to_entries[] | select(.key | startswith("dynatrace"))')
#   local name=$(context::jq -r '.review.request.object.metadata.name')s
