# Azure Arc demo

## Prereqs

### Install kubectl

``` bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### Install helm 3

``` bash
curl -LO https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz
tar -zxvf helm-v3.7.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
```

### Register providers and install az cli extensions

``` bash
az provider register -n 'Microsoft.Kubernetes'
az provider register -n 'Microsoft.KubernetesConfiguration'
az extension add --name aks-preview
az extension add --name connectedk8s
az extension add --name k8s-configuration
```

## Create a primary cluster

``` bash
az aks create --resource-group rg-aks-primary --name aks-primary-cluster --enable-managed-identity -l westeurope --node-count 1 -s Standard_B4ms --kubernetes-version 1.21.2
az aks get-credentials --resource-group rg-aks-primary --name aks-primary-cluster --admin
```

## Onboard Kubernetes clusters to Azure Arc

[link](arc-onboarding.md)

## Enable and use GitOps to deploy in cluster resources

[link](gitops.md)

## Deploy and manage Kubernetes clusters with the Cluster API

[link](cluster-api.md)
