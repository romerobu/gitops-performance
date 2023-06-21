#!/bin/bash

objects_by_app=${1}

dir=$(pwd)

rm apps/app-chart/templates/*-2.yaml
rm apps/app-chart/templates/*-3.yaml

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

    sh scripts/update-pacakage-push.sh app-chart 

fi

