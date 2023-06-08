#!/bin/bash

set -x

# Env
export IDENTIFIER="$1" # uuid
APPS_PER_REPO=$2 # amount of apps per repo
APPS_OF_APPS=$3 # amount of apps of apps
DIR=$(pwd)
# Pending to be defined
# OBJECTS_MANAGED_BY_APP=$4 #objects managed by app

rm -rf apps/app-values/dev/*

for i in $(seq 1 $APPS_OF_APPS);do

    mkdir $DIR/apps/app-values/dev/ocp$i

    for j in $(seq 1 $APPS_PER_REPO);do

        mkdir $DIR/apps/app-values/dev/ocp$i/app$j
        cp -R $DIR/apps/app-template/. $DIR/apps/app-values/dev/ocp$i/app$j/
        yq e -i '.app-chart.app.uid = env(IDENTIFIER)' $DIR/apps/app-values/dev/ocp$i/app$j/values.yaml
        yq e -i '.uid = env(IDENTIFIER)' $DIR/apps/app-of-apps/values.yaml
        yq e -i '.uid = env(IDENTIFIER)' $DIR/apps/deploy-apps-of-apps/values.yaml
        NAMESPACE="app-$j-$i" yq e -i '.app-chart.app.namespace = env(NAMESPACE)' $DIR/apps/app-values/dev/ocp$i/app$j/values.yaml
    
    done
done

APPS_OF_APPS=$(($APPS_OF_APPS+1)) yq e -i '.amount = env(APPS_OF_APPS)' $DIR/apps/app-of-apps/values.yaml
APPS_OF_APPS=$(($APPS_OF_APPS+1)) yq e -i '.amount = env(APPS_OF_APPS)' $DIR/apps/deploy-apps-of-apps/values.yaml

cd $DIR/apps/app-of-apps/

git add .
git commit -m "updating repo for testing"
echo "Pushing data to remote server!!!"
git push -u origin main

cd ../../

helm dep up apps/deploy-apps-of-apps/