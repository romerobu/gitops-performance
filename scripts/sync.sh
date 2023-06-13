
#!/bin/bash

## Env
identifier=${1}
label=${2}
apps_per_repo=${3}
apps_of_apps=${4}
iteration=${5}

dir=$(pwd)

sh scripts/update-repo.sh ${identifier} ${label}
sh scripts/update-pacakage-push.sh app-values
        

rm -rf apps/deploy-apps-of-apps/openshift
helm template apps/deploy-apps-of-apps/ --output-dir apps/deploy-apps-of-apps/openshift

oc apply -f apps/deploy-apps-of-apps/openshift/deploy-apps-of-apps/templates/

echo "Updated repository: $(date '+%m/%d/%Y %H:%M:%S')" >> ${dir}/results/iteration-${iteration}/${identifier}/data

token=$(oc whoami -t)
url="https://prometheus-k8s-openshift-monitoring.apps.cluster-j2d2t.j2d2t.sandbox545.opentlc.com/api"

export total_apps=$((${apps_per_repo} * ${apps_of_apps} + ${apps_of_apps}))
export total_deployments=$((${apps_per_repo} * ${apps_of_apps}))

while [ true ];
do
    echo "Syncing hasn't sarted yet..."
    output=$(oc get deployment -l app=${label} -A |  grep -v NAME | wc -l)
    out_of_sync=$(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=argocd_app_info" | jq -e '[.data.result[]? | select (.metric.sync_status == "OutOfSync")] | length == 0 ')
    echo "->" ${output}
    echo "->" ${out_of_sync}
    if [[ ${out_of_sync} == false || ${output} != 0 ]];
    then
        test_start=$(date '+%m/%d/%Y %H:%M:%S')
        start_in_seconds=$(date --date "${test_start}" +%s)
        echo "Sync starts: ${test_start}"
        echo "Sync starts: ${test_start}" >> ${dir}/results/iteration-${iteration}/${identifier}/data
        break
    fi
done


while [ true ];
do  
    echo "Syncing in progress..."
    output=$(oc get deployment -l app=${label} -A |  grep -v NAME | wc -l)
    echo ${output}
    if [[ ${output} > 0 && ${output} == ${total_deployments} ]];
    then
        break
    fi
done

while [ true ];
do
    if [[ $(oc get deployment -l app=${label} -A |  grep -v NAME | wc -l) == ${total_deployments} ]];
    then

        if [[ $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=argocd_app_info" | jq -e '[.data.result[]? | select (.metric.sync_status == "Synced" and .metric.health_status == "Healthy")] | length == $ENV.total_apps ') ]];
        then

            echo "Sync has finished.."
            current_time=$(date '+%m/%d/%Y %H:%M:%S')
            echo "Sync finished : ${current_time}" >> ${dir}/results/iteration-${iteration}/${identifier}/data
            current_in_seconds=$(date --date "${current_time}" +%s)
            diff=$((current_in_seconds - start_in_seconds))
            echo "Sync duration was: ${diff}" >> ${dir}/results/iteration-${iteration}/${identifier}/data
            echo "Time: " $diff
            echo "All synced and healthy "
            break

        fi
    fi
done

echo "Sync duration was: ${diff} in seconds"