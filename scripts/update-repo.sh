#!/bin/bash

set -x

echo "Updating repo for testing"

#yq e -i '.app.uid = env(IDENTIFIER)' app/values.yaml
#yq e -i '.app.labels = env(APP_NAME)' app/values.yaml

IDENTIFIER=$1 find apps/app-values/dev/*/*/values.yaml -exec yq e -i '.app-chart.app.uid = env(IDENTIFIER)' {} \;
APP_NAME=$2 find apps/app-values/dev/*/*/values.yaml -exec yq e -i '.app-chart.app.labels = env(APP_NAME)' {} \;

