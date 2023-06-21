#!/bin/bash

# Install yq and jq

dir=$(pwd)
iteration=$(date '+%m-%d-%Y-%H:%M:%S')
mkdir -p ${dir}/results
mkdir ${dir}/results/iteration-${iteration}
touch ${dir}/results/iteration-${iteration}/results.csv
echo 'nº;id;start_time;end_time;objects_by_app;apps_per_repo;app_of_apps;amount_apps_sync;sync_freq;repo_size;argo_api_req;webhook;annotation;sync_dur_1;sync_dur_2;app_controller_restart;app_reconcile_95;git_req_dur_ls_95;git_req_dur_fetch_95;repo_pen_req;exec_pen_req;app_reconcile_inc;k8s_req_total;cpu_avg_usage;cpu_avg_usage_%;cpu_max_usage;cpu_limit_%;memory_avg_usage;memory_avg_usage_%;memory_max_usage;memory_limit_%' > ${dir}/results/iteration-${iteration}/results.csv 


{
    read
    while IFS=: read -r p1 p2 p3 p4 p5 p6 p7 p8 p9 p10; 
    do 
        case $p1 in
            ''|\#*) continue ;;         # skip blank lines and lines starting with #
        esac
        
        # Delete pod to restart resource consumption and other issues caused by the last execution
        
        oc delete pod --all -n gitops-test

        oc wait pods -n gitops-test --for condition=Ready --timeout=300s --all

        id=$p1
        objects_by_app=$p2
        apps_per_repo=$p3
        apps_of_apps=$p4
        apps_sync=$p5
        sync_freq=$p6
        repo_size=$p7
        api_req=$p8
        webhook=$p9
        annotation=$p10

        printf 'Nº test: %s, Objects by app: %s, Apps per repo: %s, App of apps: %s, Apps syn: %s , Sync freq: %s , Repo size: %s  , API Req: %s , Webhook: %s , Annotation: %s \n' "${id}" "${objects_by_app}" "${apps_per_repo}" "${apps_of_apps}" "${apps_sync}" "${sync_freq}" "${repo_size}" "${api_req}" "${webhook}" "${annotation}"

        test_start=$(date '+%m/%d/%Y %H:%M:%S')
        identifier=$RANDOM

        # Create objects
        echo "ID: " ${identifier}

        export PATH_TO_RESULTS="${dir}/results/iteration-${iteration}/${id}-${identifier}"
        mkdir ${PATH_TO_RESULTS}
        touch ${PATH_TO_RESULTS}/data

        # Run Argo API load testing in parallel
        k6 run ${dir}/scripts/stress-argo-api.js --vus ${api_req} --summary-export=${PATH_TO_RESULTS}/load-testing-summary.json > ${PATH_TO_RESULTS}/load-testing-logs &

        echo "Execution ID: ${identifier}" > ${PATH_TO_RESULTS}/data
        echo "Objects by app: ${objects_by_app}" >> ${PATH_TO_RESULTS}/data
        echo "Apps per repo: ${apps_per_repo}" >> ${PATH_TO_RESULTS}/data
        echo "Apps of apps: ${apps_of_apps}" >> ${PATH_TO_RESULTS}/data
        echo "Sync frequency: ${sync_freq}" >> ${PATH_TO_RESULTS}/data
        echo "Apps to be synced: ${apps_sync}" >> ${PATH_TO_RESULTS}/data
        echo "Annotation path: ${annotation}" >> ${PATH_TO_RESULTS}/data
        
        sh scripts/create-workloads.sh ${identifier} ${apps_per_repo} ${apps_of_apps} ${annotation}
        
        if [ ${sync_freq} -ge 1 ]; then

            echo "Sync 1"

            if [[ ${objects_by_app} -eq 5 ]]; then

                total_deployments=$(echo "${apps_per_repo} * ${apps_of_apps}" | bc)

            elif [[ ${objects_by_app} -eq 10 ]]; then

                total_deployments=$(echo "2 * ${apps_per_repo} * ${apps_of_apps}" | bc)

            elif [[ ${objects_by_app} -eq 15 ]]; then

                total_deployments=$(echo "3 * ${apps_per_repo} * ${apps_of_apps}" | bc)

            fi

            echo "Total deployments: " ${total_deployments}
            
            # Initial sync sets initial label (app-name) to all apps (total_deployments)

            sh scripts/objects_by_chart.sh ${objects_by_app}
            sh scripts/sync_workload.sh ${identifier} app-name ${iteration} ${id} 100 ${apps_of_apps}
            sh scripts/sync.sh "${id}-${identifier}" app-name ${apps_per_repo} ${apps_of_apps} ${iteration} 1 ${total_deployments}

            echo "All done"
        fi

        sleep 2

        if [ ${sync_freq} -ge 2 ]; then
  
            echo "Sync 2"

            if [[ ${objects_by_app} -eq 5 ]]; then

                total_deployments=$(echo "${apps_per_repo} * ${apps_of_apps} * ${apps_sync}/100" | bc)

            elif [[ ${objects_by_app} -eq 10 ]]; then

                total_deployments=$(echo "2 * ${apps_per_repo} * ${apps_of_apps} * ${apps_sync}/100" | bc)

            elif [[ ${objects_by_app} -eq 15 ]]; then

                total_deployments=$(echo "3 * ${apps_per_repo} * ${apps_of_apps} * ${apps_sync}/100" | bc)

            fi
            
            echo "Total deployments: ${total_deployments} - " 
            sh scripts/sync_workload.sh ${identifier} app-${identifier} ${iteration} ${id} ${apps_sync} ${apps_of_apps}
            sh scripts/sync.sh "${id}-${identifier}" "app-${identifier}" ${apps_per_repo} ${apps_of_apps} ${iteration} 2 ${total_deployments}

            echo "All done"
        fi

        sleep 2

        if [ ${sync_freq} -eq 3 ]; then
            
            echo "Sync 3"

            if [[ ${objects_by_app} -eq 5 ]]; then

                total_deployments=$(echo "${apps_per_repo} * ${apps_of_apps} * ${apps_sync}/100" | bc)

            elif [[ ${objects_by_app} -eq 10 ]]; then

                total_deployments=$(echo "2 * ${apps_per_repo} * ${apps_of_apps} * ${apps_sync}/100" | bc)

            elif [[ ${objects_by_app} -eq 15 ]]; then

                total_deployments=$(echo "3 * ${apps_per_repo} * ${apps_of_apps} * ${apps_sync}/100" | bc)

            fi

            echo "Total deployments: " ${total_deployments}
            sh scripts/sync_workload.sh ${identifier} "app-${identifier}-2" ${iteration} ${id} ${apps_sync} ${apps_of_apps}
            sh scripts/sync.sh "${id}-${identifier}" "app-${identifier}-2" ${apps_per_repo} ${apps_of_apps} ${iteration} 3 ${total_deployments}

            echo "All done"
        fi

        # Then get metrics and alerts fired during the test

        current_time=$(date '+%m/%d/%Y %H:%M:%S')
        start_in_seconds=$(date --date "${test_start}" +%s)
        current_in_seconds=$(date --date "${current_time}" +%s)
        diff=$((current_in_seconds - start_in_seconds))

        sync_dur1=0
        sync_dur2=0

        input="${PATH_TO_RESULTS}/data"
        while IFS= read -r line
        do

            if [[ "$line" == *"Sync duration (in seconds) for "* ]];
            then
              entry="$line"
              stringarray=($entry)
              sync_iter=${stringarray[5]}
              sync_dur=${stringarray[7]}
              echo "Found: ---> $sync_iter and $sync_dur "
              if [[ ${sync_iter} -eq 1 ]];
              then
                sync_dur1=${sync_dur}

                echo "Sync 1 ---> $sync_iter and $sync_dur1 "
              fi
              if [[ ${sync_iter} -eq 2 ]];
              then
                sync_dur2=${sync_dur}

                echo "Sync 2 ---> $sync_iter and $sync_dur2 "                
              fi
            fi
        done < "$input"
        
    
        sh scripts/get-metrics.sh ${diff} "${id}-${identifier}" "iteration-${iteration}" ${results} ${id} "${test_start}" "${current_time}" ${objects_by_app} ${apps_per_repo} ${apps_of_apps} ${apps_sync} ${sync_freq} ${repo_size} ${api_req} ${webhook} ${annotation} ${sync_dur1} ${sync_dur2}
        
        # Finish load testing
        process=$(pgrep k6)
        echo "Killing process..." ${process}
        kill -INT ${process}

        sh scripts/clean-environment.sh ${identifier}
    done 
    
} < ${dir}/tests.txt