#!/bin/bash

set -x

echo "Updating repo for testing"

#yq e -i '.app.uid = env(IDENTIFIER)' app/values.yaml
#yq e -i '.app.labels = env(APP_NAME)' app/values.yaml

identifier=$1 find apps/app-values/dev/*/*/values.yaml -exec yq e -i '.app-chart.app.uid = env(identifier)' {} \;
app_name=$2 find apps/app-values/dev/*/*/values.yaml -exec yq e -i '.app-chart.app.labels = env(app_name)' {} \;
