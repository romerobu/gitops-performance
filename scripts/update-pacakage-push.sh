#!/bin/bash

set -x

repo=$1 # app-chart, app-library or app-values

cd apps/${repo}

if [ "${repo}" = "app-library" ]; then

    helm package .
    git add .
    git commit -m "updating repo for testing"
    git push -u origin main

elif [ "${repo}" = "app-chart" ]; then
    
    #helm repo update
    rm app-chart-*.tgz
    echo $(pwd)
    #helm dep up
    helm package .
    git add .
    git commit -m "updating repo for testing"
    git push -u origin main

elif [ "${repo}" = "app-values" ]; then

    find $(pwd)/dev/ocp*/app*/ -maxdepth 0 -type d | parallel helm dep update

    git add .
    git commit -m "updating repo for testing"
    git push -u origin main

fi
