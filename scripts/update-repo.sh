#!/bin/bash

set -x

## Env
IDENTIFIER=$1
APP_NAME=$2

echo "Updating repo for testing"

#yq e -i '.app.uid = env(IDENTIFIER)' app/values.yaml
#yq e -i '.app.labels = env(APP_NAME)' app/values.yaml

yq e -i '.app.uid = $ENV.IDENTIFIER' app/values.yaml
yq e -i '.app.labels = $ENV.APP_NAME' app/values.yaml

# find app-values/dev/ocp3/*/values.yaml -exec yq e -i '.app-chart.app.uid = env(IDENTIFIER)' {} \;
# find app-values/dev/ocp3/*/values.yaml -exec yq e -i '.app-chart.app.labels = env(APP_NAME)' {} \;

cd app/

git add .
git commit -m "updating repo for testing"

echo "Pushing data to remote server!!!"
git push -u origin master



## with charts and packages

# make changes

helm dependency update app/app-values/

# build packages and push

# 