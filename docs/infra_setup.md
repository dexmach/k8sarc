# Setup of the demo environment

To get started follow the next steps, grouped per component (infra, push container image, ...)

### Prerequisites

Install the following pre-requisites locally:

- kubectl
- helm

#### Install kubectl

``` bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

#### Install helm 3


``` bash
curl -LO https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz
tar -zxvf helm-v3.7.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
```

#### Register providers and install az cli extensions

Arc requires a couple of providers and CLI extensions.

``` bash
az provider register -n 'Microsoft.Kubernetes'
az provider register -n 'Microsoft.KubernetesConfiguration'
az extension add --name aks-preview
az extension add --name connectedk8s
az extension add --name k8s-configuration
```

### Infrastructure

In addition to the prerequisites we need some basic infrastructure components.

#### Container registry

Deploy the container registry using the container-registry.bicep file.

The bicep file expects a single parameter, the projectShortName.

``` bash

subid="<SUBSCRIPTIONID>"
resourcegroup="<RESOURCEGROUP>"

az login
az account set --subscription $subid
az deployment group create --template-file ./container-registry.bicep --parameters projectName=cnc

```

Once the container registry is created, upload a sample docker image.
This demo uses the docker image [hithere](https://github.com/Stijnc/container-template/tree/main/app) which can be customized using environment variables to align with the demo audience.

``` bash

projectName="<PROJECTNAME>"

az acr login --name $projectName
docker tag "<HITHERE>" ${projectName}.azurecr.io/${projectName}/demo:v0.1.0
docker push ${projectName}.azurecr.io/${projectName}/demo:v0.1.0

```

####  Primary Kubernetes cluster

The primary Kubernetes cluster will be used as a management cluster.
Use the following CLI commands to deploy the cluster.

``` bash
az aks create --resource-group rg-aks-primary --name aks-primary-cluster --enable-managed-identity -l westeurope --node-count 1 -s Standard_B4ms --kubernetes-version 1.21.2
az aks get-credentials --resource-group rg-aks-primary --name aks-primary-cluster --admin
```
