#!/bin/bash

# Install yq and jq

DIR=$(pwd)
ITERATION=$(date '+%m-%d-%Y-%H:%M:%S')
mkdir -p $DIR/results
mkdir $DIR/results/iteration-$ITERATION
touch $DIR/results/iteration-$ITERATION/results.csv
echo 'nº,id,start_time,end_time,objects_by_app,apps_per_repo,amount_apps_sync,sync_freq,repo_size,crds,app_of_apps,concurrent_proc' > $DIR/results/iteration-$ITERATION/results.csv 

TOKEN=$(oc whoami -t)
QUERY="sum(argocd_app_info)+by+(sync_status)"
URL="https://prometheus-k8s-openshift-monitoring.apps.cluster-c2djb.c2djb.sandbox3098.opentlc.com/api"

{
    read
    while IFS=: read -r p1 p2 p3; 
    do 
        case $p1 in
            ''|\#*) continue ;;         # skip blank lines and lines starting with #
        esac
        
        # Delete pod to restart resource consumption and other issues caused by the last execution
        
        oc delete pod --all -n gitops-test
        sleep 5

        printf 'Nº test: %s, Apps per repo: %s, Apps of apps: %s\n' "$p1" "$p2" "$p3"

        APPS_PER_REPO=$p2
        APPS_OF_APPS=$p3
        TEST_START=$(date '+%m/%d/%Y %H:%M:%S')
        IDENTIFIER=$RANDOM

        # Create objects
        echo "ID: " $IDENTIFIER

        mkdir $DIR/results/iteration-$ITERATION/$IDENTIFIER/
        touch $DIR/results/iteration-$ITERATION/$IDENTIFIER/data
        ARGO_SERVER=$(oc get route -n gitops-test argocd-server  -o jsonpath='{.spec.host}')
        ADMIN_PASSWORD=$(oc get secret argocd-cluster -n gitops-test  -o jsonpath='{.data.admin\.password}' | base64 -d)

        argocd login $ARGO_SERVER --username admin --password $ADMIN_PASSWORD --insecure

        echo "Execution ID: $IDENTIFIER" > $DIR/results/iteration-$ITERATION/$IDENTIFIER/data
        echo "Apps per repo: $APPS_PER_REPO" >> $DIR/results/iteration-$ITERATION/$IDENTIFIER/data
        echo "Apps of apps: $APPS_OF_APPS" >> $DIR/results/iteration-$ITERATION/$IDENTIFIER/data

        sh scripts/create-workloads.sh $IDENTIFIER $APPS_PER_REPO $APPS_OF_APPS
        sh scripts/update-repo.sh $IDENTIFIER app-name
        sh scripts/update-pacakage-push.sh app-values
        
        rm -rf apps/deploy-apps-of-apps/openshift
        helm template apps/deploy-apps-of-apps/ --output-dir apps/deploy-apps-of-apps/openshift
        oc apply -f apps/deploy-apps-of-apps/openshift/deploy-apps-of-apps/templates/
        
        # Detect when initial sync has finished

        while true;
        do  

            if [ $(curl -s -g -k -X GET -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -H 'Content-Type: application/json' "$URL/v1/query?query=$QUERY" | jq -e '.data.result[0]? | select (.metric.sync_status == "Synced") | (.value[1] == $ENV.AMOUNT_APPS)') ];
                
            then
                break
            fi
            echo "Waiting for apps to be synced..."
                
        done

        # Push changes and sync apps

        sh scripts/update-repo.sh $IDENTIFIER app-$IDENTIFIER
        sh scripts/update-pacakage-push.sh app-values
        
        rm -rf apps/deploy-apps-of-apps/openshift
        helm template apps/deploy-apps-of-apps/ --output-dir apps/deploy-apps-of-apps/openshift
        oc apply -f apps/deploy-apps-of-apps/openshift/deploy-apps-of-apps/templates/
        # log when repo was updated

        # Detect when syncing has finished
        sleep 182
        # log when reconcile interval ends

        while true;
        do  

            if [ $(curl -s -g -k -X GET -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -H 'Content-Type: application/json' "$URL/v1/query?query=$QUERY" | jq -e '.data.result[0]? | select (.metric.sync_status == "Synced") | (.value[1] == $ENV.AMOUNT_APPS)') ];
            then
                break
            fi
            echo "Waiting for apps to be synced..."    
        done
        # log when sync ends

        sh scripts/update-repo.sh $IDENTIFIER app-$IDENTIFIER-2
        sh scripts/update-pacakage-push.sh app-values
        
        rm -rf apps/deploy-apps-of-apps/openshift
        helm template apps/deploy-apps-of-apps/ --output-dir apps/deploy-apps-of-apps/openshift
        oc apply -f apps/deploy-apps-of-apps/openshift/deploy-apps-of-apps/templates/

        sleep 182

        while true;
        do  

            if [ $(curl -s -g -k -X GET -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -H 'Content-Type: application/json' "$URL/v1/query?query=$QUERY" | jq -e '.data.result[0]? | select (.metric.sync_status == "Synced") | (.value[1] == $ENV.AMOUNT_APPS)') ];
            then
                break
            fi
            echo "Waiting for apps to be synced..."
                
        done

        # Then get metrics and alerts fired during the test

        CURRENT_TIME=$(date '+%m/%d/%Y %H:%M:%S')
        START_IN_SECONDS=$(date --date "$TEST_START" +%s)
        CURRENT_IN_SECONDS=$(date --date "$CURRENT_TIME" +%s)
        diff=$((CURRENT_IN_SECONDS - START_IN_SECONDS))

        sh scripts/get-metrics.sh $diff $IDENTIFIER iteration-$ITERATION

        sh scripts/clean-environment.sh $IDENTIFIER

        echo "$p1,$IDENTIFIER,$TEST_START,$CURRENT_TIME,objects_by_app,$AMOUNT_APPS,amount_apps_sync,sync_freq,repo_size,crds,app_of_apps,concurrent_proc" >> $DIR/results/iteration-$ITERATION/results.csv 
    done 
    
} < $DIR/tests.txt






