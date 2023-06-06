#!/bin/bash

set -x

## Env
IDENTIFIER=$1
APP_NAME=$2

echo "Updating repo for testing"

export IDENTIFIER
export APP_NAME

yq e -i '.app.uid = env(IDENTIFIER)' app/values.yaml
yq e -i '.app.appname = env(APP_NAME)' app/values.yaml

cd app/

git add .
git commit -m "updating repo for testing"

echo "Pushing data to remote server!!!"
git push -u origin master
