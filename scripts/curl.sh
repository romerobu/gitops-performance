
token=$(oc whoami -t)
query1="sum(round(increase(argocd_app_sync_total[10m])))+by+(name)"
query2="argocd_app_info[5s]"
url="https://prometheus-k8s-openshift-monitoring.apps.cluster-j2d2t.j2d2t.sandbox545.opentlc.com/api"


while true;
do 
   echo -e "\n -------------------------------> \n"
   curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query1}"  
   sleep 5
   #current_time=$(date '+%m/%d/%Y %H:%M:%S')
   #current_in_seconds=$(date --date "${current_time}" +%s)
   #echo -e "\n -------------------------------> \n"
   #curl -s -g -k -X GET -H "Authorization: Bearer ${token}" -H 'Accept: application/json' -H 'Content-Type: application/json' "${url}/v1/query?query=${query2}"  
done