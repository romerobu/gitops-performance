#!/bin/bash

identifier=${1}
label=${2}
iteration=${3}
id=${4}
apps_to_be_synced=${5}
apps_of_apps=${6}

dir=$(pwd)

sh scripts/update-repo.sh ${identifier} ${label} ${apps_to_be_synced} ${apps_of_apps}
sh scripts/update-pacakage-push.sh app-values
        
rm -rf apps/deploy-apps-of-apps/openshift
helm template apps/deploy-apps-of-apps/ --output-dir apps/deploy-apps-of-apps/openshift

oc apply -f apps/deploy-apps-of-apps/openshift/deploy-apps-of-apps/templates/

echo "Updated repository: $(date '+%m/%d/%Y %H:%M:%S')" >> ${dir}/results/iteration-${iteration}/${id}-${identifier}/data