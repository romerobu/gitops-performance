#!/bin/bash

set -x

apps_to_be_synced=${3}
apps_of_apps=${4}

apps=$(echo "${apps_of_apps} * ${apps_to_be_synced}/100 " | bc)


find apps/app-values/dev -type d -name "ocp[0-9]*" -exec bash -c 'x=$(basename "{}" | sed "s/ocp//"); if (( x <= "$1" )); then find apps/app-values/dev/$(basename "{}")/*/values.yaml ; fi' bash ${apps} \; | xargs -I {} sh -c "identifier=${1} yq e -i '.app-chart.app.uid = env(identifier)' {}"
find apps/app-values/dev -type d -name "ocp[0-9]*" -exec bash -c 'x=$(basename "{}" | sed "s/ocp//"); if (( x <= "$1" )); then find apps/app-values/dev/$(basename "{}")/*/values.yaml ; fi' bash ${apps} \; | xargs -I {} sh -c "app_name=${2} yq e -i '.app-chart.app.labels = env(app_name)' {}"
