## Run terraform to deploy the infrastructure for PAS

```bash
cd ~/ops-manager-automation/pivotal-cf-terraforming-gcp-*/terraforming-pas/
ln -s ~/ops-manager-automation/pivotal-cf-terraforming-gcp-*/terraform.tfvars .
terraform init
terraform apply --auto-approve
```
