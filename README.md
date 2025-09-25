# Azure-Private-Infra

### Setup Infrastructure in Azure

#### Prerequisite

- terraform binary installed
- Azure Credentials

#### Terraform Apply

Set below environment variables and run terraform apply command to bring up the infrastructure

```
export ARM_CLIENT_ID=<client id>
export ARM_TENANT_ID=<tenant id>
export ARM_SUBSCRIPTION_ID=<subscription id>
export ARM_CLIENT_SECRET=<password or client secret>
```

```
terraform init
terraform plan
terraform apply
```
Note: Change to `terraform` directory, where all the terraform configuration files are present, before running above commands.

### Deploy application/services in K8s cluster

#### Prerequisite

- Make sure your connected to k8s cluster and have access to deploy pods/services on it.

#### kubectl Apply

- Run below command to deploy frontend, backend services on k8s

```
kubectl apply -k k8s-deployments/Kustomize/base
```

### Steps to install cert-manager

1. Install cert-manager 

```
helm repo add jetstack https://charts.jetstack.io --force-update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.2 \
  --set crds.enabled=true
```

2. Install Cluster Issuer and Certificate resource as below. 

```
kubectl apply -f cert-manager/cluster-issuer-http.yaml
kubectl apply -f cert-manager/certificate.yaml
```
Note: Above uses lets encrypt to generate the TLS certificate