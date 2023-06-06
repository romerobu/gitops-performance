#!/bin/bash

set -x

## Env
TIME=${1}
IDENTIFIER=${2}
ITERATION=${3}

DIR=$(pwd)

export TOKEN=$( oc whoami -t)
export URL=https://prometheus-k8s-openshift-monitoring.apps.cluster-68cmn.68cmn.sandbox2789.opentlc.com/api

echo -e "Duration: " $TIME "s \n" >> $DIR/results/$IDENTIFIER/data
mkdir $DIR/results/$ITERATION/$IDENTIFIER/metrics

# Run querys

# QUERY 1

touch $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-1.json

QUERY1="histogram_quantile(0.95,rate(argocd_app_reconcile_bucket[$TIME"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -H 'Content-Type: application/json' "$URL/v1/query?query=$QUERY1") > $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-1.json
echo "Metric app reconcile bucket 0.95 quantile: " >> $DIR/results/$ITERATION/$IDENTIFIER/data
echo "  " $(jq '.data.result[0].value[1]' $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-1.json) >> $DIR/results/$ITERATION/$IDENTIFIER/data

# QUERY 2

touch $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-2.json

QUERY2="histogram_quantile(0.95,rate(argocd_git_request_duration_seconds_bucket{request_type='ls-remote'}[$TIME"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -H 'Content-Type: application/json' "$URL/v1/query?query=$QUERY2") > $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-2.json
echo "Metric argo git request duration bucket for ls-remote 0.95 quantile: " >> $DIR/results/$ITERATION/$IDENTIFIER/data
echo "  " $(jq '.data.result[0].value[1]' $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-2.json) >> $DIR/results/$ITERATION/$IDENTIFIER/data

# QUERY 3

touch $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-3.json

QUERY3="histogram_quantile(0.95,rate(argocd_git_request_duration_seconds_bucket{request_type='fetch'}[$TIME"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -H 'Content-Type: application/json' "$URL/v1/query?query=$QUERY3") > $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-3.json
echo "Metric argo git request duration bucket for fetch 0.95 quantile: " >> $DIR/results/$ITERATION/$IDENTIFIER/data
echo "  " $(jq '.data.result[0].value[1]' $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-3.json) >> $DIR/results/$ITERATION/$IDENTIFIER/data

# QUERY 4

touch $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-4.json

QUERY4="avg_over_time(argocd_repo_pending_request_total[$TIME"s"])"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -H 'Content-Type: application/json' "$URL/v1/query?query=$QUERY4") > $DIR/results/$IDENTIFIER/metrics/query-4.json
echo "Metric argo repo pending requests: " >> $DIR/results/$ITERATION/$IDENTIFIER/data
echo "  " $(jq '.data.result[0].value[1]' $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-4.json) >> $DIR/results/$ITERATION/$IDENTIFIER/data

# QUERY 5

touch $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-5.json

QUERY5="avg_over_time(argocd_kubectl_exec_pending[$TIME"s"])"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -H 'Content-Type: application/json' "$URL/v1/query?query=$QUERY5") > $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-5.json
echo "Metric argo kubectl exec pending requests: " >> $DIR/results/$ITERATION/$IDENTIFIER/data
echo "  " $(jq '.data.result[0].value[1]' $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-5.json) >> $DIR/results/$ITERATION/$IDENTIFIER/data

# QUERY 6

touch $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-6.json

QUERY6="sum(increase(argocd_app_reconcile_count[$TIME"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -H 'Content-Type: application/json' "$URL/v1/query?query=$QUERY6") > $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-6.json
echo "Metric argo app reconcile count increasement: " >> $DIR/results/$ITERATION/$IDENTIFIER/data
echo "  " $(jq '.data.result[0].value[1]' $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-6.json) >> $DIR/results/$ITERATION/$IDENTIFIER/data

# QUERY 7

touch $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-7.json

QUERY7="sum+by+(name)(increase(argocd_app_k8s_request_total[$TIME"s"]))"

echo $(curl -s -g -k -X GET -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -H 'Content-Type: application/json' "$URL/v1/query?query=$QUERY7") > $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-7.json
echo "Metric argo app reconcile count increasement: " >> $DIR/results/$ITERATION/$IDENTIFIER/data
echo "  " $(jq '.data.result[].metric.name' $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-7.json) $(jq '.data.result[].value[1]' $DIR/results/$ITERATION/$IDENTIFIER/metrics/query-7.json) >> $DIR/results/$ITERATION/$IDENTIFIER/data

# ALERTS

touch $DIR/results/$ITERATION/$IDENTIFIER/metrics/alerts.json

echo $(curl -s -g -k -X GET -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -H 'Content-Type: application/json' "$URL/v1/query?query=ALERTS") > $DIR/results/$ITERATION/$IDENTIFIER/metrics/alerts.json
echo "Alerts firing: " >> $DIR/results/$ITERATION/$IDENTIFIER/data
echo "  " $(jq '.data.result[].metric.alertname' $DIR/results/$ITERATION/$IDENTIFIER/metrics/alerts.json) >> $DIR/results/$ITERATION/$IDENTIFIER/data


# Get alerts
# https://prometheus.io/docs/prometheus/latest/querying/api/#rules
# curl -s -g -k -X GET -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -H 'Content-Type: application/json' "$URL/v1/query?query=ALERTS" 
