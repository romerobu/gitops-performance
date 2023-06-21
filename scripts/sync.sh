
#!/bin/bash

identifier=${1}
label=${2}
apps_per_repo=${3}
apps_of_apps=${4}
iteration=${5}
sync_freq=${6}
apps_to_be_synced=${7}

dir=$(pwd)

token=$(oc whoami -t)
url="https://prometheus-k8s-openshift-monitoring.apps.cluster-nl29n.nl29n.sandbox1228.opentlc.com/api"

export total_apps=$((${apps_per_repo} * ${apps_of_apps} + ${apps_of_apps}))

echo "Total applications: ${total_apps}"
echo "Total deployments expected to be updated for sync: ${apps_to_be_synced}" 
echo "Total deployments expected to be updated: ${apps_to_be_synced}"  >> ${dir}/results/iteration-${iteration}/${identifier}/data

while [ true ];
do
    echo "Syncing hasn't sarted yet..."
    output=$(oc get deployment -l app=${label} -A |  grep -v NAME | wc -l)
    out_of_sync=$(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=argocd_app_info" | jq -e '[.data.result[]? | select (.metric.sync_status == "OutOfSync")] | length == 0 ')
    #echo "->" ${output}
    #echo "->" ${out_of_sync}
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
    if [[ ${output} > 0 && ${output} == ${apps_to_be_synced} ]];
    then
        break
    fi
done

while [ true ];
do
    if [[ $(oc get deployment -l app=${label} -A |  grep -v NAME | wc -l) == ${apps_to_be_synced} ]];
    then
    
        sleep 5

        if [[ $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=argocd_app_info" | jq -e '[.data.result[]? | select (.metric.sync_status == "Synced" and .metric.health_status == "Healthy")] | length == $ENV.total_apps ') ]];
        then

            echo "Sync has finished.."
            current_time=$(date '+%m/%d/%Y %H:%M:%S')
            echo "Sync finished : ${current_time}" >> ${dir}/results/iteration-${iteration}/${identifier}/data
            current_in_seconds=$(date --date "${current_time}" +%s)
            diff=$((current_in_seconds - start_in_seconds))
            echo "Sync duration was: " $diff
            echo "All synced and healthy "
            break

        fi
    fi
done

echo "Sync duration (in seconds) for ${sync_freq} : ${diff}" >> ${dir}/results/iteration-${iteration}/${identifier}/data