#!/bin/bash

set -x

# Env

IDENTIFIER=$1 # uuid
APPS=$2 # amount of apps

export APPS
export IDENTIFIER
# Create apps with uid from execution

echo "Updating initial repo..."

sh ./update-repo.sh $IDENTIFIER app-name

yq e -i '.amount = env(APPS)' application/values.yaml
yq e -i '.uid = env(IDENTIFIER)' application/values.yaml

rm -rf application/openshift

helm template application/ --output-dir application/openshift

oc apply -f ./application/openshift/applications/templates
