#!/bin/bash

set -x

## Env
REPO=$1


echo "Updating repo for testing"

cd ../apps/$REPO

if [ "$REPO" = "app-library" ]; then

    helm package .
    git add .
    git commit -m "updating repo for testing"
    echo "Pushing data to remote server!!!"
    git push -u origin main

elif [ "$REPO" = "app-chart" ]; then
    
    helm repo update
    helm dep up
    helm package .
    git add .
    git commit -m "updating repo for testing"
    echo "Pushing data to remote server!!!"
    git push -u origin main

elif [ "$REPO" = "app-values" ]; then

    for app in /dev/ocp3/*/values.yaml; do
        cd  /dev/ocp3/$app
        helm repo update
        helm dep up
        git add .
        git commit -m "updating repo for testing"
        echo "Pushing data to remote server!!!"
        git push -u origin main
        cd ../../../
    done

fi

