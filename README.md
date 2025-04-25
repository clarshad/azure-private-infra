# Azure-Private-Infra

### Steps

#### Prerequisite

terraform binary installed
Azure Credentials

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