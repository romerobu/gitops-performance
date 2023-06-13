#!/bin/bash

set -x

# Env
export identifier="$1" # uuid
apps_per_repo=$2 # amount of apps per repo
apps_of_apps=$3 # amount of apps of apps
dir=$(pwd)
# Pending to be defined
# OBJECTS_MANAGED_BY_APP=$4 #objects managed by app

rm -rf $dir/apps/app-values/dev/*

for i in $(seq 1 ${apps_of_apps});do

    mkdir ${dir}/apps/app-values/dev/ocp$i

    for j in $(seq 1 ${apps_per_repo});do

        mkdir ${dir}/apps/app-values/dev/ocp$i/app$j
        cp -R ${dir}/apps/app-template/. ${dir}/apps/app-values/dev/ocp$i/app$j/
        yq e -i '.app-chart.app.uid = env(identifier)' ${dir}/apps/app-values/dev/ocp$i/app$j/values.yaml
        yq e -i '.uid = env(identifier)' ${dir}/apps/app-of-apps/values.yaml
        yq e -i '.uid = env(identifier)' ${dir}/apps/deploy-apps-of-apps/values.yaml
        namespace="app-$i-$j" yq e -i '.app-chart.app.namespace = env(namespace)' ${dir}/apps/app-values/dev/ocp$i/app$j/values.yaml
    
    done
done

apps_of_apps=$((${apps_of_apps}+1)) yq e -i '.amount = env(apps_of_apps)' ${dir}/apps/app-of-apps/values.yaml
apps_per_repo=$((${apps_per_repo}+1)) yq e -i '.set = env(apps_per_repo)' ${dir}/apps/app-of-apps/values.yaml
apps_of_apps=$((${apps_of_apps}+1)) yq e -i '.amount = env(apps_of_apps)' ${dir}/apps/deploy-apps-of-apps/values.yaml
apps_per_repo=$((${apps_per_repo}+1)) yq e -i '.set = env(apps_per_repo)' ${dir}/apps/deploy-apps-of-apps/values.yaml

cd ${dir}/apps/app-of-apps/

git add .
git commit -m "updating repo for testing"
echo "Pushing data to remote server!!!"
git push -u origin main

cd ../../
helm dep up apps/deploy-apps-of-apps/