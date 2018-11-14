# [ops-manager-automation](../README.md) / ops-manager-gcp

## Prerequisites

On GCP:
- A pristine GCP project
- An SSH session on a pristine Ubuntu jumpbox with `gcloud` initialized ([click here](../jumpbox-gcp/README.md))

## SSH to your jumpbox (if necessary)

```bash
gcloud compute ssh ubuntu@jbox-pcf --zone us-central1-a
```

## Enable the GCP services APIs in current project

```bash
gcloud services enable compute.googleapis.com && \
gcloud services enable iam.googleapis.com && \
gcloud services enable cloudresourcemanager.googleapis.com && \
gcloud services enable dns.googleapis.com && \
gcloud services enable sqladmin.googleapis.com
```

## Install some essential tools

Elevate privileges:

```bash
sudo su -
```

Install tools:

```bash
apt update && apt --yes install unzip jq build-essential ruby-dev

gem install --no-ri --no-rdoc cf-uaac

wget -O terraform.zip https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip && \
  unzip terraform.zip && \
  mv terraform /usr/local/bin
  
wget -O om https://github.com/pivotal-cf/om/releases/download/0.41.0/om-linux && \
  chmod +x om && \
  mv om /usr/local/bin/
  
wget -O pivnet https://github.com/pivotal-cf/pivnet-cli/releases/download/v0.0.54/pivnet-linux-amd64-0.0.54 && \
  chmod +x pivnet && \
  mv pivnet /usr/local/bin/
  
wget -O bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-5.3.1-linux-amd64 && \
  chmod +x bosh && \
  mv bosh /usr/local/bin/
```

Verify that these tools were installed:

```bash
which uaac; which terraform; which om; which pivnet; which bosh
```

Remember to return to the shell with regular privileges:

```bash
exit
```

## Clone _this_ repo

From the jumpbox:

```bash
git clone https://github.com/amcginlay/ops-manager-automation.git ~/ops-manager-automation

# [or clone with SSH]
git clone git@github.com:amcginlay/ops-manager-automation.git ~/ops-manager-automation
```

## Create a configuration file

Let's change into the directory of our cloned repo to keep our task 
script commands short:

```bash
cd ~/ops-manager-automation
```

From your jumpbox, create a `~/.env` configuration file to describe the 
specifics of your environment.

```bash
./scripts/create-env.sh
```

_Note_ you should not proceed until you have __customized__ the settings 
in your `~/.env` file to suit your target environment

## Register the configuration file

Now that we have the `~/.env` file with our critical variables, we need 
to ensure that these get set into the shell, both now and every 
subsequent time the ubuntu user connects to the jumpbox.

```bash
source ~/.env
echo "source ~/.env" >> ~/.bashrc
```

To review your currently active variable settings:

```bash
set | grep PCF
```

## Create a GCP services account for terraform in current project

```bash
gcloud iam service-accounts create terraform --display-name terraform

gcloud iam service-accounts keys create 'gcp_credentials.json' \
  --iam-account "terraform@$(gcloud config get-value core/project).iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $(gcloud config get-value core/project) \
  --member "serviceAccount:terraform@$(gcloud config get-value core/project).iam.gserviceaccount.com" \
  --role 'roles/owner'
```

## Download an Ops Manager image identifier from Pivotal Network

```bash
PRODUCT_NAME="Pivotal Cloud Foundry Operations Manager" \
DOWNLOAD_REGEX="Pivotal Cloud Foundry Ops Manager YAML for GCP" \
PRODUCT_VERSION=2.3.0 \
  ./scripts/download-product.sh

OPSMAN_IMAGE=$(bosh interpolate ./downloads/ops-manager*/OpsManager*onGCP.yml --path /us)
```

## Download and unzip the Terraform scripts from Pivotal Network

```bash
PRODUCT_NAME="Pivotal Application Service (formerly Elastic Runtime)" \
DOWNLOAD_REGEX="GCP Terraform Templates" \
PRODUCT_VERSION=2.3.0 \
  ./scripts/download-product.sh
    
unzip ./downloads/elastic-runtime*/terraforming-gcp-*.zip -d .
```

## Generate a wildcard SAN certificate

```no-highlight
./scripts/mk-ssl-cert-key.sh
```

## Create the `terraform.tfvars` file

```bash
cd ./pivotal-cf-terraforming-gcp-*

cat > ./terraform.tfvars <<-EOF
env_name            = "${PCF_SUBDOMAIN_NAME}"
project             = "$(gcloud config get-value core/project)"
region              = "${PCF_REGION}"
zones               = ["${PCF_AZ_2}", "${PCF_AZ_1}", "${PCF_AZ_3}"]
dns_suffix          = "${PCF_DOMAIN_NAME}"
opsman_image_url    = "https://storage.googleapis.com/${OPSMAN_IMAGE}"
create_gcs_buckets  = "false"
external_database   = "false"
isolation_segment   = "false"
pks                 = "true"
ssl_cert            = <<SSL_CERT
$(cat ../${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.crt)
SSL_CERT
ssl_private_key     = <<SSL_KEY
$(cat ../${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.key)
SSL_KEY
service_account_key = <<SERVICE_ACCOUNT_KEY
$(cat ../gcp_credentials.json)
SERVICE_ACCOUNT_KEY
EOF
```

## Run terraform to deploy your Ops Manager VM

```bash
terraform init
terraform apply --auto-approve
```

This will take about 5 minutes to complete but you should allow some 
extra time for the DNS updates to propagate.

Once `dig` can resolve the Ops Manager FQDN to an IP address within its __AUTHORITY SECTION__, we're good to move on.  This may take about 5 minutes from your local machine.

```bash
watch dig ${PCF_OPSMAN_FQDN}
```

The above step is fully dependent on having a ${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME} NS record-set attached to your registered domain.  This record-set must point to _every_ google domain server, for example:

(screenshot from [AWS Route 53](https://aws.amazon.com/route53))

![route_53_ns](route_53_ns.png)

# Next Step

- [Return to the main document](../README.md#first-steps)
