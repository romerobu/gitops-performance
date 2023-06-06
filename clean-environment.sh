#!/bin/bash

set -x

IDENTIFIER=${1} # uuid
DIR=$(pwd)

oc delete Application -l app.kubernetes.io/id=$IDENTIFIER -A
oc delete all -l app.kubernetes.io/id=$IDENTIFIER -A
oc delete Namespace -l app.kubernetes.io/id=$IDENTIFIER

#rm -rf $DIR/results/$IDENTIFIER