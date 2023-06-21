oc login -u kubeadmin -p KwyMM-S3NVV-E2iFi-2k7gx https://api.cluster-nl29n.nl29n.sandbox1228.opentlc.com:6443

oc apply -f argo-configuration/1-gitops-test-namespace.yaml
oc apply -f argo-configuration/2-gitops-subscription.yaml 
sleep 60 # wait for operator to be installed
oc apply -f argo-configuration/3-argocd.yaml
oc apply -f argo-configuration/4-sa-rolebinding-gitops-test.yaml
oc apply -f argo-configuration/5-sa-rolebinding-openshit-gitops.yaml

ARGO_SERVER=$(oc get route -n gitops-test argocd-server  -o jsonpath='{.spec.host}')
ADMIN_PASSWORD=$(oc get secret argocd-cluster -n gitops-test  -o jsonpath='{.data.admin\.password}' | base64 -d)
ARGOCD_TOKEN=$(argocd account generate-token --account test)

echo "Argo server: " $ARGO_SERVER
echo "Argo admin password: " $ADMIN_PASSWORD
echo "Argo test token: " $ARGOCD_TOKEN

oc apply -f argo-configuration/6-grafana-subscription.yaml
sleep 60
oc apply -f argo-configuration/7-grafana-instance.yaml
sleep 60 # wait for operator to be installed
oc project grafana
oc adm policy add-cluster-role-to-user cluster-monitoring-view -z grafana-serviceaccount

SECRET_TOKEN=$(oc get secrets -n grafana | awk '{print $1}' | grep grafana-serviceaccount-token-*)
export BEARER_TOKEN="Bearer "$(oc get secret $SECRET_TOKEN -n grafana  -o jsonpath='{.data.token}' | base64 -d)
yq e -i '.spec.datasources[0].secureJsonData.httpHeaderValue1 = env(BEARER_TOKEN)' argo-configuration/8-grafana-ds.yaml
oc apply -f argo-configuration/8-grafana-ds.yaml

GRAFANA_ROUTE=$(oc get route grafana-route -n grafana)
GRAFANA_PASSWORD=$(oc get secret grafana-admin-credentials -n grafana  -o jsonpath='{.data.GF_SECURITY_ADMIN_PASSWORD}' | base64 -d)

echo "Grafana admin password:" $GRAFANA_PASSWORD
echo "Grafana route: " $GRAFANA_ROUTE
