# Azure Arc onboarding

## Prereqs

Deploy a VM that has access to the public internet on port 443 with a minimum of 2 cpu and 2gb ram.

### Install docker

``` bash
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo groupadd docker
sudo usermod -aG docker $USER
# exit and login again
```

### Install kind

``` bash
curl -Lo kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
sudo install -o root -g root -m 0755 kind /usr/local/bin/kind
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### Install Azure CLI

``` bash
SubscriptionId=""

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login
az account set --subscription $SubscriptionId

az provider register -n 'Microsoft.Kubernetes'
az provider register -n 'Microsoft.KubernetesConfiguration'
az extension add --name aks-preview
az extension add --name connectedk8s
az extension add --name k8s-configuration
```

## Start demo

### Create a new cluster & onboard it to Azure Arc

<!---
(5m)
portal overview of the azure arc for kubernetes extension
see what it deploys in the cluster
-->

``` bash
cat <<EOF | kind create cluster --name edge-hardware-02 --kubeconfig=~/edge-hardware-02.yaml --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
kind get kubeconfig --name edge-hardware-02 > edge-hardware-02.yaml
export KUBECONFIG=~/edge-hardware-02.yaml
az connectedk8s connect --name edge-hardware-02 --resource-group rg-aks-arc
```

### Enable monitoring extension

<!---
(1m)
https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/extensions#currently-available-extensions
see helm chart in cluster
https://github.com/microsoft/Docker-Provider/tree/ci_dev/charts/azuremonitor-containers
https://github.com/microsoft/Docker-Provider/tree/ci_dev/scripts/onboarding/templates/arc-k8s-extension
-->

![cluster extensions](https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/media/conceptual-extensions.png)

``` bash
LogAnalyticsWorkspaceResourceID=""

az k8s-extension create --name azuremonitor-containers --cluster-name edge-hardware-02 --resource-group rg-aks-arc --cluster-type connectedClusters --extension-type Microsoft.AzureMonitor.Containers --configuration-settings logAnalyticsWorkspaceResourceID=$LogAnalyticsWorkspaceResourceID
```

### Enable connecting to the cluster from anywhere

![connected k8s](https://i.imgur.com/yxHJRNg.png)

``` bash
az connectedk8s enable-features --features cluster-connect --name edge-hardware-02 --resource-group rg-aks-arc
```

#### Test from any other location with internet access

``` bash
az connectedk8s proxy --name edge-hardware-02 --resource-group rg-aks-arc -f edge-hardware-02.kubeconfig
# other terminal
export KUBECONFIG=$PWD/edge-hardware-01.kubeconfig
kubectl get po -A
```

### Allow access to the cluster

``` bash
ADUser=""

kubectl create clusterrolebinding admin-user-binding --clusterrole cluster-admin --user=$ADUser
```

### Clean up

``` bash
kubectl delete clusterrolebinding admin-user-binding
az connectedk8s delete --name edge-hardware-02 --resource-group rg-aks-arc
unset KUBECONFIG
kind delete cluster --name edge-hardware-02
rm ~/edge-hardware-02.yaml
```
