#!/bin/bash

set -x

identifier=${1} # uuid

oc delete Application -l app.kubernetes.io/id=${identifier} -A
oc delete all -l app.kubernetes.io/id=${identifier} -A
oc delete Namespace -l app.kubernetes.io/id=${identifier}
