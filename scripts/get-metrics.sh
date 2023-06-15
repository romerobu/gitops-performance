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
export url=https://prometheus-k8s-openshift-monitoring.apps.cluster-j2d2t.j2d2t.sandbox545.opentlc.com/api

echo -e "Duration: " ${time} "s \n" >> ${dir}/results/${iteration}/${identifier}/data
mkdir ${dir}/results/${iteration}/${identifier}/metrics

# Run querys

echo -e "\nMetrics: \n" >> ${dir}/results/${iteration}/${identifier}/data

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
result_query3=$(jq '.data.result[0].value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-3.json)
echo "  " ${result_query3} >> ${dir}/results/${iteration}/${identifier}/data

# query 4

touch ${dir}/results/${iteration}/${identifier}/metrics/query-4.json

query4="avg_over_time(argocd_repo_pending_request_total[${time}"s"])"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query4}") > ${dir}/results/${identifier}/metrics/query-4.json
echo "Metric argo repo pending requests: " >> ${dir}/results/${iteration}/${identifier}/data
result_query4=$(jq '.data.result[0].value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-4.json)
echo "  " ${result_query4} >> ${dir}/results/${iteration}/${identifier}/data

# query 5

touch ${dir}/results/${iteration}/${identifier}/metrics/query-5.json

query5="avg_over_time(argocd_kubectl_exec_pending[${time}"s"])"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query5}") > ${dir}/results/${iteration}/${identifier}/metrics/query-5.json
echo "Metric argo kubectl exec pending requests: " >> ${dir}/results/${iteration}/${identifier}/data
result_query5=$(jq '.data.result[0].value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-4.json)
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
echo "Metric argo app reconcile count increasement: " >> ${dir}/results/${iteration}/${identifier}/data
result_query7=$(jq '.data.result[].metric.name' ${dir}/results/${iteration}/${identifier}/metrics/query-7.json)
echo "  " ${result_query7} >> ${dir}/results/${iteration}/${identifier}/data

# ALERTS

touch ${dir}/results/${iteration}/${identifier}/metrics/alerts.json

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=ALERTS") > ${dir}/results/${iteration}/${identifier}/metrics/alerts.json
echo "Alerts firing: " >> ${dir}/results/${iteration}/${identifier}/data
echo "  " $(jq '.data.result[].metric.alertname' ${dir}/results/${iteration}/${identifier}/metrics/alerts.json) >> ${dir}/results/${iteration}/${identifier}/data


echo "${test_number},${identifier},${test_start},${current_time},${objects_by_app},${apps_per_repo},${apps_of_apps},${amount_apps_sync},${sync_freq},${repo_size},${argo_api_req},${webhook},${annotation},${sync_dur1},${sync_dur2},${result_query1},${result_query2},${result_query3},${result_query4},${result_query5},${result_query6},pending_to_be_fixed" >> ${dir}/results/${iteration}/results.csv


# Get alerts
# https://prometheus.io/docs/prometheus/latest/querying/api/#rules
# curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=ALERTS" 
