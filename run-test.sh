#!/bin/bash

# Install yq and jq

dir=$(pwd)
iteration=$(date '+%m-%d-%Y-%H:%M:%S')
mkdir -p ${dir}/results
mkdir ${dir}/results/iteration-${iteration}
touch ${dir}/results/iteration-${iteration}/results.csv
echo 'nº,id,start_time,end_time,objects_by_app,apps_per_repo,amount_apps_sync,sync_freq,repo_size,crds,app_of_apps,concurrent_proc' > ${dir}/results/iteration-${iteration}/results.csv 


{
    read
    while IFS=: read -r p1 p2 p3 p4; 
    do 
        case $p1 in
            ''|\#*) continue ;;         # skip blank lines and lines starting with #
        esac
        
        # Delete pod to restart resource consumption and other issues caused by the last execution
        
        oc delete pod --all -n gitops-test
        sleep 5

        printf 'Nº test: %s, Apps per repo: %s, Apps of apps: %s, Sync frequency: %s\n' "$p1" "$p2" "$p3" "$p4"

        apps_per_repo=$p2
        apps_of_apps=$p3
        sync_freq=$p4

        test_start=$(date '+%m/%d/%Y %H:%M:%S')
        identifier=$RANDOM

        # Create objects
        echo "ID: " ${identifier}

        export PATH_TO_RESULTS="${dir}/results/iteration-${iteration}/${identifier}"
        mkdir ${PATH_TO_RESULTS}
        touch ${PATH_TO_RESULTS}/data

        argo_server=$(oc get route -n gitops-test argocd-server  -o jsonpath='{.spec.host}')
        admin_password=$(oc get secret argocd-cluster -n gitops-test  -o jsonpath='{.data.admin\.password}' | base64 -d)
        argocd login ${argo_server} --username admin --password ${admin_password} --insecure

        echo "Execution ID: ${identifier}" > ${PATH_TO_RESULTS}/data
        echo "Apps per repo: ${apps_per_repo}" >> ${PATH_TO_RESULTS}/data
        echo "Apps of apps: ${apps_of_apps}" >> ${PATH_TO_RESULTS}/data
        echo "Sync frequency: ${sync_freq}" >> ${PATH_TO_RESULTS}/data
        
        sh scripts/create-workloads.sh ${identifier} ${apps_per_repo} ${apps_of_apps}
        
        if [ ${sync_freq} -ge 1 ]; then
            
            echo "Sync 1"
            sh scripts/sync.sh ${identifier} app-name ${apps_per_repo} ${apps_of_apps} ${iteration}
    
        fi

        if [ ${sync_freq} -ge 2 ]; then
            
            echo "Sync 2"
            sh scripts/sync.sh ${identifier} app-${identifier} ${apps_per_repo} ${apps_of_apps} ${iteration}
    
        fi

        if [ ${sync_freq} -eq 3 ]; then
            
            echo "Sync 3"
            sh scripts/sync.sh ${identifier} app-${identifier}-2 ${apps_per_repo} ${apps_of_apps} ${iteration}
    
        fi

        # Then get metrics and alerts fired during the test

        current_time=$(date '+%m/%d/%Y %H:%M:%S')
        start_in_seconds=$(date --date "${test_start}" +%s)
        current_in_seconds=$(date --date "${current_time}" +%s)
        diff=$((current_in_seconds - start_in_seconds))

        sh scripts/get-metrics.sh ${diff} ${identifier} iteration-${iteration}

        sh scripts/clean-environment.sh ${identifier}

        echo "${p1},${identifier},${test_start},${current_time},objects_by_app,${apps_per_repo},amount_apps_sync,${sync_freq},repo_size,crds,${apps_of_apps},concurrent_proc" >> ${dir}/results/iteration-${iteration}/results.csv 
    done 
    
} < ${dir}/tests.txt

