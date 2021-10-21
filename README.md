# Arc for Kubernetes demo environment

Welcome to the Arc for Kubernetes demo environment



## Demo overview

all the steps:


## Setup your environment

To get started follow the next steps, grouped per component (infra, push container image, ...)

### Infrastructure

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



## Demo sessions

[Cloud Native Community - Using Kubernetes in a Hybrid Cloud with Azure Arc (28/10/2021)](https://dexmach.cloudnativecommunity.com/webinar-using-kubernetes-in-a-hybrid-cloud-with-azure-arc/)

## Additional info

Find below some additional info about the topics addressed during this demo.

- [Azure Arc for Kubernetes]()
- [GitOps using Arc for Kubernetes]()
- [GitOps]()
