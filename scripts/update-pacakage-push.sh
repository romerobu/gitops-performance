#!/bin/bash

set -x

repo=$1 # app-chart, app-library or app-values

cd apps/${repo}

if [ "${repo}" = "app-library" ]; then

    helm package .
    git add .
    git commit -m "updating repo for testing"
    echo "Pushing data to remote server!!!"
    git push -u origin main

elif [ "${repo}" = "app-chart" ]; then
    
    helm repo update
    helm dep up
    helm package .
    git add .
    git commit -m "updating repo for testing"
    echo "Pushing data to remote server!!!"
    git push -u origin main

elif [ "${repo}" = "app-values" ]; then


    for app in $(pwd)/dev/*/*/; do
        
        cd $app
        echo "You are here:" $(pwd)
        #helm repo update
        #helm dep update
        git add .
        git commit -m "updating repo for testing"
        echo "Pushing data to remote server!!!"
        git push -u origin main
        cd ../../../

    done

fi

