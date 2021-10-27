# Cluster API

## Install CLI

<!--
source: https://github.com/microsoft/azure_arc/blob/main/azure_arc_k8s_jumpstart/cluster_api/capi_azure/
-->

``` bash
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v0.4.4/clusterctl-linux-amd64 -o clusterctl
sudo install -o root -g root -m 0755 clusterctl /usr/local/bin/clusterctl
```

## Cluster API setup

``` bash
clusterctl init --infrastructure=azure:v0.5.3
# Manual fix for kubenet usage: <https://azure.github.io/aad-pod-identity/docs/configure/aad_pod_identity_on_kubenet/#how-to-run-aad-pod-identity-on-clusters-with-kubenet>
```

## Install a cluster

``` bash
export AZURE_SUBSCRIPTION_ID=""

az account set --subscription=${AZURE_SUBSCRIPTION_ID}
az ad sp create-for-rbac -n "azure-cluster-api" --role contributor

export AZURE_CLIENT_ID=""
export AZURE_CLIENT_SECRET=""
export AZURE_TENANT_ID=""
export AZURE_CLUSTER_IDENTITY_SECRET_NAME="capz-cluster-01-secret"
export AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE="capz-cluster-01"
export AZURE_CONTROL_PLANE_MACHINE_TYPE="Standard_D2s_v3"
export CAPI_WORKLOAD_CLUSTER_NAME="capz-cluster-01"
export AZURE_LOCATION="westeurope"
export AZURE_NODE_MACHINE_TYPE="Standard_D2s_v3"
export CLUSTER_IDENTITY_NAME="capz-cluster-01-identity"

kubectl create ns ${AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE}
kubectl create secret -n ${AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE} generic ${AZURE_CLUSTER_IDENTITY_SECRET_NAME} --from-literal=clientSecret="${AZURE_CLIENT_SECRET}"
clusterctl generate cluster ${CAPI_WORKLOAD_CLUSTER_NAME} \
  -n ${AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE} \
  --kubernetes-version v1.20.10 \
  --control-plane-machine-count=1 \
  --worker-machine-count=1 \
  > ${CAPI_WORKLOAD_CLUSTER_NAME}.yaml

az k8s-configuration create \
    --name aks-primary-cluster --resource-group rg-aks-primary --cluster-name aks-primary-cluster \
    --operator-instance-name global-configuration \
    --operator-namespace azure-gitops \
    --repository-url https://github.com/dexmach/k8sarc \
    --scope cluster \
    --cluster-type managedClusters \
    --operator-params "--git-poll-interval 10s --git-readonly --git-path=operations/aks-azure,operations/common,clusters --git-branch main" \
    --enable-helm-operator --helm-operator-chart-version='1.4.0' --helm-operator-params='--set helm.versions=v3'

kubectl get cluster -A

clusterctl get kubeconfig -n ${AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE} ${CAPI_WORKLOAD_CLUSTER_NAME} > ${CAPI_WORKLOAD_CLUSTER_NAME}.kubeconfig
export KUBECONFIG=$PWD/${CAPI_WORKLOAD_CLUSTER_NAME}.kubeconfig
kubectl get no
kubectl get po -A
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/cluster-api-provider-azure/master/templates/addons/calico.yaml
```

## Cleanup

``` bash
az k8s-configuration delete  --name aks-primary-cluster --resource-group rg-aks-primary --cluster-name aks-primary-cluster --cluster-type managedClusters
kubectl delete cluster -n capz-cluster-01 capz-cluster-01
```
