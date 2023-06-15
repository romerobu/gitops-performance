#!/bin/bash

set -x

apps_to_be_synced=${3}
apps_of_apps=${4}

apps=$(echo "scale=3; ${apps_to_be_synced}/100 * ${apps_of_apps}" | bc)

identifier=${1} find apps/app-values/dev/ocp[1-${apps}]/*/values.yaml -exec yq e -i '.app-chart.app.uid = env(identifier)' {} \;
app_name=${2} find apps/app-values/dev/ocp[1-${apps}]/*/values.yaml -exec yq e -i '.app-chart.app.labels = env(app_name)' {} \;
