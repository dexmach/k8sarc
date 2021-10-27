# GitOps

## Prepare the git repo

### cluster administrator repo

``` text
operations folder
|-- <cluster-name>
  |-- <non-namespaced-workloads>
  |-- <namespace>
    |-- <rbac>
    |-- <limits>
    |-- <cluster-workloads>

```

<!--
flux helm operator & helm releases, compare with https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx
-->

### application repo

deploy folder

``` text
|-- manifests OR kustomize OR helm chart

```


## Onboard an AKS cluster directly

<!--
2m onboarding
view portal gitops extension
view resource graph
automatically onboard all clusters with azure policy <https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Fc050047b-b21b-4822-8a2d-c1e37c3c0c6a>
kubectl get helmreleases -A
helm ls -A & view values
-->

``` bash
az aks enable-addons --resource-group rg-aks-primary --name aks-primary-cluster --addons gitops
az k8s-configuration create \
    --name aks-primary-cluster --resource-group rg-aks-primary --cluster-name aks-primary-cluster \
    --operator-instance-name global-configuration \
    --operator-namespace azure-gitops \
    --repository-url https://github.com/dexmach/k8sarc \
    --scope cluster \
    --cluster-type managedClusters \
    --operator-params "--git-poll-interval 10s --git-readonly --git-path=operations/aks-azure,operations/common --git-branch main" \
    --enable-helm-operator --helm-operator-chart-version='1.4.0' --helm-operator-params='--set helm.versions=v3'
```

## edge clusters (arc onboarded)

``` bash
az k8s-configuration create \
    --name edge-hardware-02 --resource-group rg-aks-arc --cluster-name edge-hardware-02 \
    --operator-instance-name global-configuration \
    --operator-namespace azure-gitops \
    --repository-url https://github.com/dexmach/k8sarc \
    --scope cluster \
    --cluster-type connectedClusters \
    --operator-params "--git-poll-interval 10s --git-readonly --git-path=operations/aks-edge,operations/common --git-branch main" \
    --enable-helm-operator --helm-operator-chart-version='1.4.0' --helm-operator-params='--set helm.versions=v3'
```

## onboard the sample app

``` bash
az k8s-configuration create \
    --name sample-app-config --resource-group rg-aks-primary --cluster-name aks-primary-cluster \
    --operator-instance-name sample-app-config \
    --operator-namespace demo \
    --repository-url https://github.com/dexmach/k8sarc \
    --scope namespace \
    --cluster-type managedClusters \
    --operator-params "--git-poll-interval 10s --git-readonly --git-path=sample-app-repo/deploy --git-branch main"

az k8s-configuration create \
    --name sample-app-config --resource-group rg-aks-arc --cluster-name edge-hardware-02 \
    --operator-instance-name sample-app-config \
    --operator-namespace demo \
    --repository-url https://github.com/dexmach/k8sarc \
    --scope namespace \
    --cluster-type connectedClusters \
    --operator-params "--git-poll-interval 10s --git-readonly --git-path=sample-app-repo/deploy --git-branch main"
```

### Flux v1 vs Flux v2

all differences: <https://fluxcd.io/docs/migration/faq-migration/#what-are-significant-new-differences-between-flux-v1-and-flux-v2>

## Clean up

``` bash
az k8s-configuration delete --name edge-hardware-02 --resource-group rg-aks-arc --cluster-name edge-hardware-02 --cluster-type connectedClusters
az k8s-configuration delete --name sample-app-config --resource-group rg-aks-arc --cluster-name edge-hardware-02 --cluster-type connectedClusters
az k8s-configuration delete --name aks-primary-cluster --resource-group rg-aks-primary --cluster-name aks-primary-cluster --cluster-type managedClusters
az k8s-configuration delete --name sample-app-config --resource-group rg-aks-primary --cluster-name aks-primary-cluster --cluster-type managedClusters
az aks disable-addons --resource-group rg-aks-primary --name aks-primary-cluster --addons gitops
```
