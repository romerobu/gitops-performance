#!/bin/bash

set -x

## Env
time=${1}
identifier=${2}
iteration=${3}

dir=$(pwd)

export token=$( oc whoami -t)
export url=https://prometheus-k8s-openshift-monitoring.apps.cluster-j2d2t.j2d2t.sandbox545.opentlc.com/api

echo -e "Duration: " ${time} "s \n" >> ${dir}/results/${identifier}/data
mkdir ${dir}/results/${iteration}/${identifier}/metrics

# Run querys

# query 1

touch ${dir}/results/${iteration}/${identifier}/metrics/query-1.json

query1="histogram_quantile(0.95,rate(argocd_app_reconcile_bucket[${time}"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query1}") > ${dir}/results/${iteration}/${identifier}/metrics/query-1.json
echo "Metric app reconcile bucket 0.95 quantile: " >> ${dir}/results/${iteration}/${identifier}/data
echo "  " $(jq '.data.result[0].value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-1.json) >> ${dir}/results/${iteration}/${identifier}/data

# query 2

touch ${dir}/results/${iteration}/${identifier}/metrics/query-2.json

query2="histogram_quantile(0.95,rate(argocd_git_request_duration_seconds_bucket{request_type='ls-remote'}[${time}"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query2}") > ${dir}/results/${iteration}/${identifier}/metrics/query-2.json
echo "Metric argo git request duration bucket for ls-remote 0.95 quantile: " >> ${dir}/results/${iteration}/${identifier}/data
echo "  " $(jq '.data.result[0].value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-2.json) >> ${dir}/results/${iteration}/${identifier}/data

# query 3

touch ${dir}/results/${iteration}/${identifier}/metrics/query-3.json

query3="histogram_quantile(0.95,rate(argocd_git_request_duration_seconds_bucket{request_type='fetch'}[${time}"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query3}") > ${dir}/results/${iteration}/${identifier}/metrics/query-3.json
echo "Metric argo git request duration bucket for fetch 0.95 quantile: " >> ${dir}/results/${iteration}/${identifier}/data
echo "  " $(jq '.data.result[0].value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-3.json) >> ${dir}/results/${iteration}/${identifier}/data

# query 4

touch ${dir}/results/${iteration}/${identifier}/metrics/query-4.json

query4="avg_over_time(argocd_repo_pending_request_total[${time}"s"])"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query4}") > ${dir}/results/${identifier}/metrics/query-4.json
echo "Metric argo repo pending requests: " >> ${dir}/results/${iteration}/${identifier}/data
echo "  " $(jq '.data.result[0].value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-4.json) >> ${dir}/results/${iteration}/${identifier}/data

# query 5

touch ${dir}/results/${iteration}/${identifier}/metrics/query-5.json

query5="avg_over_time(argocd_kubectl_exec_pending[${time}"s"])"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query5}") > ${dir}/results/${iteration}/${identifier}/metrics/query-5.json
echo "Metric argo kubectl exec pending requests: " >> ${dir}/results/${iteration}/${identifier}/data
echo "  " $(jq '.data.result[0].value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-5.json) >> ${dir}/results/${iteration}/${identifier}/data

# query 6

touch ${dir}/results/${iteration}/${identifier}/metrics/query-6.json

query6="sum(increase(argocd_app_reconcile_count[${time}"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query6}") > ${dir}/results/${iteration}/${identifier}/metrics/query-6.json
echo "Metric argo app reconcile count increasement: " >> ${dir}/results/${iteration}/${identifier}/data
echo "  " $(jq '.data.result[0].value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-6.json) >> ${dir}/results/${iteration}/${identifier}/data

# query 7

touch ${dir}/results/${iteration}/${identifier}/metrics/query-7.json

query7="sum+by+(name)(increase(argocd_app_k8s_request_total[${time}"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query7}") > ${dir}/results/${iteration}/${identifier}/metrics/query-7.json
echo "Metric argo app reconcile count increasement: " >> ${dir}/results/${iteration}/${identifier}/data
echo "  " $(jq '.data.result[].metric.name' ${dir}/results/${iteration}/${identifier}/metrics/query-7.json) $(jq '.data.result[].value[1]' ${dir}/results/${iteration}/${identifier}/metrics/query-7.json) >> ${dir}/results/${iteration}/${identifier}/data

# ALERTS

touch ${dir}/results/${iteration}/${identifier}/metrics/alerts.json

echo $(curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=ALERTS") > ${dir}/results/${iteration}/${identifier}/metrics/alerts.json
echo "Alerts firing: " >> ${dir}/results/${iteration}/${identifier}/data
echo "  " $(jq '.data.result[].metric.alertname' ${dir}/results/${iteration}/${identifier}/metrics/alerts.json) >> ${dir}/results/${iteration}/${identifier}/data


# Get alerts
# https://prometheus.io/docs/prometheus/latest/querying/api/#rules
# curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=ALERTS" 
