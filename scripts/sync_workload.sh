#!/bin/bash

identifier=${1}
label=${2}
iteration=${3}
id=${4}
apps_to_be_synced=${5}
apps_of_apps=${6}
objects_by_app=${7}

dir=$(pwd)

sh scripts/update-repo.sh ${identifier} ${label} ${apps_to_be_synced} ${apps_of_apps}

if [[ ${objects_by_app} -eq 10 ]];
then 

    cp -R apps/objects-by-app/*-2.yaml apps/app-chart/templates/
    sh scripts/update-pacakage-push.sh app-chart    

elif [[ ${objects_by_app} -eq 15 ]];
then

    cp -R apps/objects-by-app/*-2.yaml apps/app-chart/templates/
    cp -R apps/objects-by-app/*-3.yaml apps/app-chart/templates/
    sh scripts/update-pacakage-push.sh app-chart 

elif [[  ${objects_by_app} -eq 5 ]];
then

    rm apps/app-chart/templates/*-2.yaml
    rm apps/app-chart/templates/*-3.yaml
    sh scripts/update-pacakage-push.sh app-chart 

fi

sleep 5

sh scripts/update-pacakage-push.sh app-values
        
rm -rf apps/deploy-apps-of-apps/openshift
helm template apps/deploy-apps-of-apps/ --output-dir apps/deploy-apps-of-apps/openshift

oc apply -f apps/deploy-apps-of-apps/openshift/deploy-apps-of-apps/templates/

echo "Updated repository: $(date '+%m/%d/%Y %H:%M:%S')" >> ${dir}/results/iteration-${iteration}/${id}-${identifier}/data