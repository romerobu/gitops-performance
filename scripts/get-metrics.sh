#!/bin/bash

set -x

## Env
time=${1}
identifier=${2}
iteration=${3}
test_number=${4}
test_start=${5}
current_time=${6}
objects_by_app=${7}
apps_per_repo=${8}
apps_of_apps=${9}
amount_apps_sync=${10}
sync_freq=${11}
repo_size=${12}
argo_api_req=${13}
webhook=${14}
annotation=${15}
sync_dur1=${16}
sync_dur2=${17}

dir=$(pwd)

export token=$( oc whoami -t)
export url=https://prometheus-k8s-openshift-monitoring.apps.cluster-nl29n.nl29n.sandbox1228.opentlc.com/api

echo -e "Duration: " ${time} "s \n" >> ${dir}/results/${iteration}/${identifier}/data
mkdir ${dir}/results/${iteration}/${identifier}/metrics

echo "Pod restarts: " >> ${dir}/results/${iteration}/${identifier}/data
echo "  $(oc get pods -n gitops-test -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .status.containerStatuses[*]}{.restartCount}{", "}{end}{end}')" >> ${dir}/results/${iteration}/${identifier}/data


# Run querys

echo -e "\nMetrics: \n" >> ${dir}/results/${iteration}/${identifier}/data

# Gitops pods restarts

result_pod_restart=$(oc get pod -n gitops-test argocd-application-controller-0 -o jsonpath='{.status.containerStatuses[0].restartCount}')

# query 1

touch ${dir}/results/${iteration}/${identifier}/metrics/query-1.json

query1="histogram_quantile(0.95,rate(argocd_app_reconcile_bucket[${time}"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query1}") > ${dir}/results/${iteration}/${identifier}/metrics/query-1.json
echo "Metric app reconcile bucket 0.95 quantile: " >> ${dir}/results/${iteration}/${identifier}/data
result_query1=$(jq '.data.result[0].value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-1.json)
echo "  " ${result_query1} >> ${dir}/results/${iteration}/${identifier}/data

# query 2

touch ${dir}/results/${iteration}/${identifier}/metrics/query-2.json

query2="histogram_quantile(0.95,rate(argocd_git_request_duration_seconds_bucket{request_type='ls-remote'}[${time}"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query2}") > ${dir}/results/${iteration}/${identifier}/metrics/query-2.json
echo "Metric argo git request duration bucket for ls-remote 0.95 quantile: " >> ${dir}/results/${iteration}/${identifier}/data
result_query2=$(jq '.data.result[0].value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-2.json)
echo "  " ${result_query2} >> ${dir}/results/${iteration}/${identifier}/data

# query 3

touch ${dir}/results/${iteration}/${identifier}/metrics/query-3.json

query3="histogram_quantile(0.95,rate(argocd_git_request_duration_seconds_bucket{request_type='fetch'}[${time}"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query3}") > ${dir}/results/${iteration}/${identifier}/metrics/query-3.json
echo "Metric argo git request duration bucket for fetch 0.95 quantile: " >> ${dir}/results/${iteration}/${identifier}/data
result_query3=$(jq '.data.result[1].value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-3.json)
echo "  " ${result_query3} >> ${dir}/results/${iteration}/${identifier}/data

# query 4

touch ${dir}/results/${iteration}/${identifier}/metrics/query-4.json

query4="avg_over_time(argocd_repo_pending_request_total[${time}"s"])"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query4}") > ${dir}/results/${iteration}/${identifier}/metrics/query-4.json
echo "Metric argo repo pending requests: " >> ${dir}/results/${iteration}/${identifier}/data
result_query4=$(jq -e '[.data.result[]? | .value[1] | tr '\n' ' ']' ${dir}/results/${iteration}/${identifier}/metrics/query-4.json)
echo "  " ${result_query4} >> ${dir}/results/${iteration}/${identifier}/data

# query 5

touch ${dir}/results/${iteration}/${identifier}/metrics/query-5.json

query5="avg_over_time(argocd_kubectl_exec_pending[${time}"s"])"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query5}") > ${dir}/results/${iteration}/${identifier}/metrics/query-5.json
echo "Metric argo kubectl exec pending requests: " >> ${dir}/results/${iteration}/${identifier}/data
result_query5=$(jq -e '.data.result[]? | .value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-5.json)
echo "  " ${result_query5} >> ${dir}/results/${iteration}/${identifier}/data

# query 6

touch ${dir}/results/${iteration}/${identifier}/metrics/query-6.json

query6="sum(increase(argocd_app_reconcile_count[${time}"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query6}") > ${dir}/results/${iteration}/${identifier}/metrics/query-6.json
echo "Metric argo app reconcile count increasement: " >> ${dir}/results/${iteration}/${identifier}/data
result_query6=$(jq '.data.result[0].value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-6.json)
echo "  " ${result_query6} >> ${dir}/results/${iteration}/${identifier}/data

# query 7

touch ${dir}/results/${iteration}/${identifier}/metrics/query-7.json

query7="sum+by+(name)(increase(argocd_app_k8s_request_total[${time}"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query7}") > ${dir}/results/${iteration}/${identifier}/metrics/query-7.json
echo "Metric argo app reconcile count increasement by name: " >> ${dir}/results/${iteration}/${identifier}/data
result_query7=$( | jq -e '.data.result[]? | .metric.name, .metric.value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-7.json)
echo "  " ${result_query7} >> ${dir}/results/${iteration}/${identifier}/data


# query 8 # CPU Usage avg over time

touch ${dir}/results/${iteration}/${identifier}/metrics/query-8.json

query8="avg(avg_over_time(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{cluster='',namespace='gitops-test'}[${time}"s"]))+by+(container)"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query8}") > ${dir}/results/${iteration}/${identifier}/metrics/query-8.json
echo "Metric average CPU usage over time: " >> ${dir}/results/${iteration}/${identifier}/data

result_query8=$(jq -e '[.data.result[]? | .value[1]]' ${dir}/results/${iteration}/${identifier}/metrics/query-8.json)
echo "  " ${result_query8} >> ${dir}/results/${iteration}/${identifier}/data

# query 9 # CPU Usage avg over time

touch ${dir}/results/${iteration}/${identifier}/metrics/query-9.json

query9="avg(avg_over_time(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{cluster='',namespace='gitops-test'}[${time}"s"]))+by+(pod)+/+avg(avg_over_time(cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests{cluster='',namespace='gitops-test'}[${time}"s"]))+by+(container)"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query9}") > ${dir}/results/${iteration}/${identifier}/metrics/query-9.json
echo "Metric average CPU % usage over time: " >> ${dir}/results/${iteration}/${identifier}/data

result_query9=$(jq -e '[.data.result[]? | .value[1]]' ${dir}/results/${iteration}/${identifier}/metrics/query-9.json)
echo "  " ${result_query9} >> ${dir}/results/${iteration}/${identifier}/data

# query 10 # CPU Usage max over time

touch ${dir}/results/${iteration}/${identifier}/metrics/query-10.json

query10="max(max_over_time(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{cluster='',namespace='gitops-test'}[${time}"s"]))+by+(container)"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query10}") > ${dir}/results/${iteration}/${identifier}/metrics/query-10.json
echo "Metric max CPU over time: " >> ${dir}/results/${iteration}/${identifier}/data

result_query10=$(jq -e '[.data.result[]? | .value[1]]' ${dir}/results/${iteration}/${identifier}/metrics/query-10.json)
echo "  " ${result_query10} >> ${dir}/results/${iteration}/${identifier}/data

# query 11 # CPU % Limit over time

touch ${dir}/results/${iteration}/${identifier}/metrics/query-11.json

query11="avg(avg_over_time(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{cluster='',namespace='gitops-test'}[${time}"s"]))+by+(container)+/+avg(avg_over_time(cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits{cluster='',namespace='gitops-test'}[${time}"s"]))+by+(container)"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query11}") > ${dir}/results/${iteration}/${identifier}/metrics/query-11.json
echo "Metric CPU % Limit over time: " >> ${dir}/results/${iteration}/${identifier}/data

result_query11=$(jq -e '[.data.result[]? | .value[1]]' ${dir}/results/${iteration}/${identifier}/metrics/query-11.json)
echo "  " ${result_query11} >> ${dir}/results/${iteration}/${identifier}/data

# query 12 # Memory Usage avg over time

touch ${dir}/results/${iteration}/${identifier}/metrics/query-12.json

query12="avg(avg_over_time(container_memory_working_set_bytes{job='kubelet',metrics_path='/metrics/cadvisor',cluster='',namespace='gitops-test',container!='',image!=''}[${time}"s"]))+by+(container)"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query12}") > ${dir}/results/${iteration}/${identifier}/metrics/query-12.json
echo "Metric average Memory usage over time: " >> ${dir}/results/${iteration}/${identifier}/data

result_query12=$(jq -e '[.data.result[]? | .value[1]]' ${dir}/results/${iteration}/${identifier}/metrics/query-12.json)
echo "  " ${result_query12} >> ${dir}/results/${iteration}/${identifier}/data

# query 13 # Memory Usage avg over time %

touch ${dir}/results/${iteration}/${identifier}/metrics/query-13.json

query13="avg(avg_over_time(container_memory_working_set_bytes{job='kubelet',metrics_path='/metrics/cadvisor',cluster='',namespace='gitops-test',container!='',image!=''}[${time}"s"]))+by+(container)+/+avg(avg_over_time(cluster:namespace:pod_memory:active:kube_pod_container_resource_requests{cluster="",namespace="gitops-test"}[${time}"s"]))+by+(container)"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query13}") > ${dir}/results/${iteration}/${identifier}/metrics/query-13.json
echo "Metric average Memory % usage over time: " >> ${dir}/results/${iteration}/${identifier}/data

result_query13=$(jq -e '[.data.result[]? | .value[1]]' ${dir}/results/${iteration}/${identifier}/metrics/query-13.json)
echo "  " ${result_query13} >> ${dir}/results/${iteration}/${identifier}/data

# query 14 # Memory Usage max over time

touch ${dir}/results/${iteration}/${identifier}/metrics/query-14.json

query14="max(max_over_time(container_memory_working_set_bytes{job='kubelet',metrics_path='/metrics/cadvisor',cluster='',namespace='gitops-test',container!='',image!=''}[${time}"s"]))+by+(container)+/+avg(avg_over_time(cluster:namespace:pod_memory:active:kube_pod_container_resource_requests{cluster='',namespace='gitops-test'}[${time}"s"]))+by+(container)"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query14}") > ${dir}/results/${iteration}/${identifier}/metrics/query-14.json
echo "Metric max Memory over time: " >> ${dir}/results/${iteration}/${identifier}/data

result_query14=$(jq -e '[.data.result[]? | .value[1]]' ${dir}/results/${iteration}/${identifier}/metrics/query-14.json)
echo "  " ${result_query14} >> ${dir}/results/${iteration}/${identifier}/data

# query 15 # Memory % Limit over time

touch ${dir}/results/${iteration}/${identifier}/metrics/query-15.json

query15="avg(avg_over_time(container_memory_working_set_bytes{job='kubelet',metrics_path='/metrics/cadvisor',cluster='',namespace='gitops-test',container!='',image!=''}[${time}"s"]))+by+(container)+/+avg(avg_over_time(cluster:namespace:pod_memory:active:kube_pod_container_resource_limits{cluster='',namespace='gitops-test'}[${time}"s"]))+by+(container)"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query15}") > ${dir}/results/${iteration}/${identifier}/metrics/query-15.json
echo "Metric Memory % Limit over time: " >> ${dir}/results/${iteration}/${identifier}/data

result_query15=$(jq -e '[.data.result[]? | .value[1]]' ${dir}/results/${iteration}/${identifier}/metrics/query-15.json)
echo "  " ${result_query15} >> ${dir}/results/${iteration}/${identifier}/data


# ALERTS

touch ${dir}/results/${iteration}/${identifier}/metrics/alerts.json

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=ALERTS") > ${dir}/results/${iteration}/${identifier}/metrics/alerts.json
echo "Alerts firing: " >> ${dir}/results/${iteration}/${identifier}/data
echo "  " $(jq '.data.result[].metric.alertname' ${dir}/results/${iteration}/${identifier}/metrics/alerts.json) >> ${dir}/results/${iteration}/${identifier}/data


echo "${test_number};${identifier};${test_start};${current_time};${objects_by_app};${apps_per_repo};${apps_of_apps};${amount_apps_sync};${sync_freq};${repo_size};${argo_api_req};${webhook};${annotation};${sync_dur1};${sync_dur2};${result_pod_restart};${result_query1};${result_query2};${result_query3};${result_query4};${result_query5};${result_query6};${result_query7};${result_query8};${result_query9};${result_query10};${result_query11};${result_query12};${result_query13};${result_query14};${result_query15}" >> ${dir}/results/${iteration}/results.csv


# Get alerts
# https://prometheus.io/docs/prometheus/latest/querying/api/#rules
# curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=ALERTS" 
