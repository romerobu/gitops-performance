#!/bin/bash

# Install yq and jq

# Oc login 

DIR=$(pwd)
ITERATION=$(date '+%m-%d-%Y-%H:%M:%S')
mkdir $DIR/results/iteration-$ITERATION
touch $DIR/results/iteration-$ITERATION/results.csv

{
    read
    while IFS=: read -r p1 p2; 
    do 
        printf 'Nº test: %s, Amount apps: %s\n' "$p1" "$p2"

        # AMOUNT_APPS=$p2
        # TEST_START=$(date '+%m/%d/%Y %H:%M:%S')
        # IDENTIFIER=$RANDOM

        # # Create objects
        # echo "ID: " $IDENTIFIER

        # mkdir $DIR/results/iteration-$ITERATION/$IDENTIFIER/
        # touch $DIR/results/iteration-$ITERATION/$IDENTIFIER/data
        # ARGO_SERVER=$(oc get route -n gitops-test argocd-server  -o jsonpath='{.spec.host}')
        # ADMIN_PASSWORD=$(oc get secret argocd-cluster -n gitops-test  -o jsonpath='{.data.admin\.password}' | base64 -d)

        # argocd login $ARGO_SERVER --username admin --password $ADMIN_PASSWORD --insecure

        # echo "Execution ID: $IDENTIFIER" > $DIR/results/iteration-$ITERATION/$IDENTIFIER/data
        # echo "Amount of apps: $AMOUNT_APPS" >> $DIR/results/iteration-$ITERATION/$IDENTIFIER/data

        # sh create-workloads.sh $IDENTIFIER $AMOUNT_APPS

        # # Detect when initial sync has finished

        # argocd app wait -l app.kubernetes.io/id=$IDENTIFIER

        # # Push changes and sync apps

        # sh ./update-repo.sh $IDENTIFIER app-$IDENTIFIER

        # # Detect when syncing has finished
        # sleep 200

        # argocd app wait -l app.kubernetes.io/id=$IDENTIFIER

        # sh ./update-repo.sh $IDENTIFIER app-$IDENTIFIER-2

        # sleep 200

        # argocd app wait -l app.kubernetes.io/id=$IDENTIFIER

        # # Then get metrics and alerts fired during the test

        # CURRENT_TIME=$(date '+%m/%d/%Y %H:%M:%S')
        # START_IN_SECONDS=$(date --date "$TEST_START" +%s)
        # CURRENT_IN_SECONDS=$(date --date "$CURRENT_TIME" +%s)
        # diff=$((CURRENT_IN_SECONDS - START_IN_SECONDS))

        # sh get-metrics.sh $diff $IDENTIFIER iteration-$ITERATION

        # sh clean-environment.sh $IDENTIFIER

    done 
    
} < $DIR/tests.txt






