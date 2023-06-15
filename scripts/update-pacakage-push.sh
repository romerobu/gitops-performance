#!/bin/bash

set -x

repo=$1 # app-chart, app-library or app-values

cd apps/${repo}

if [ "${repo}" = "app-library" ]; then

    helm package .
    git add .
    git commit -m "updating repo for testing" --quiet
    git push -u origin main --quiet

elif [ "${repo}" = "app-chart" ]; then
    
    helm repo update
    helm dep up
    helm package .
    git add .
    git commit -m "updating repo for testing" --quiet
    git push -u origin main --quiet

elif [ "${repo}" = "app-values" ]; then

    echo "You are here:" $(pwd)

    #find $(pwd)/dev/ocp*/app*/ -maxdepth 0 -type d | parallel helm repo update
    find $(pwd)/dev/ocp*/app*/ -maxdepth 0 -type d | parallel helm dep update
    
    dirs=$(find $(pwd)/dev/ocp*/app*/ -maxdepth 0 -type d)

    # Función para ejecutar git push en un directorio
    add_to_git() {

    echo "Git add to $(pwd)"
    git -C $1 add .

    }

    commit_to_git() {

    echo "Git commit to $(pwd)"
    git -C $1 commit -m "updating repo for testing"
    
    }

    push_to_git() {

    echo "Git push to $(pwd)"
    git -C $1 push -u origin main
    
    }

    export -f add_to_git
    export -f commit_to_git
    export -f push_to_git

    # Ejecutar en paralelo el comando push_to_git para cada directorio

    parallel add_to_git ::: "${dirs[@]}"
    sleep 2
    parallel commit_to_git ::: "${dirs[@]}"
    sleep 2
    parallel push_to_git ::: "${dirs[@]}"

    # for app in $(pwd)/dev/*/*/; do
        
    #     git -C $app add .
    #     git -C $app commit -m "updating repo for testing"
    #     git -C $app push -u origin main

    # done
    # echo "All done"

fi

