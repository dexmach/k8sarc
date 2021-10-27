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


