## Run terraform to deploy the infrastructure for PAS

```bash
cd ./terraforming-pas/
ln -s ../terraform.tfvars .
terraform init
terraform apply --auto-approve
```
