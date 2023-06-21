#!/bin/bash

export token=$( oc whoami -t)
export url=https://prometheus-k8s-openshift-monitoring.apps.cluster-nl29n.nl29n.sandbox1228.opentlc.com/api

time=50

query1="avg(avg_over_time(container_memory_working_set_bytes{job='kubelet',metrics_path='/metrics/cadvisor',cluster='',namespace='gitops-test',container!='',image!=''}[${time}"s"]))+by+(container)"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: aspplication/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query1}")