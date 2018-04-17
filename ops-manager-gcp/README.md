# [ops-manager-automation](../README.md) / ops-manager-gcp

## Prerequisites

On GCP:
- A pristine GCP project
- An SSH session on a pristine Ubuntu jumpbox with `gcloud` initialized ([click here](../jumpbox-gcp/README.md))

## SSH to your jumpbox (if necessary)

From Cloud Shell:

```bash
PCF_AZ_1=CHANGE_ME_AZ_1 # e.g. us-central1-a

gcloud compute ssh ubuntu@jumpbox \
  --project "$(gcloud config get-value core/project 2> /dev/null)" \
  --zone "${PCF_AZ_1}"
```

## Configuring jumpbox for use with private GitHub repos

To interract with private repos, we need to _generate_ an SSH key on your jumpbox and _register_ it with GitHub.

The following step are taken from the [GitHub docs](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#platform-linux).

### SSH Key Generation

```bash
GITHUB_USER=CHANGE_ME_GITHUB_USER # e.g. fbloggs@gmail.com
eval "$(ssh-agent -s)"
ssh-keygen -t rsa -b 4096 -C "${GITHUB_USER}"
ssh-add ~/.ssh/id_rsa

# inspect the public key which Github will need to know
cat ${HOME}/.ssh/id_rsa.pub
```

### SSH Key Registration

Follow these [GitHub docs](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/) to get your newly generated SSH key registered with your GitHub account.  This involves copying and pasting text between your SSH session and the GitHub website.

## Clone _this_ repo

From the jumpbox:

```bash
# [Clone with SSH]
git clone git@github.com:amcginlay/ops-manager-automation.git ${HOME}/ops-manager-automation

# [Clone with HTTPS]
git clone https://github.com/amcginlay/ops-manager-automation.git ${HOME}/ops-manager-automation
```

## Create a configuration file

From your jumpbox, create a `${HOME}/.env` configuration file to describe the specifics of your environment.

```bash
${HOME}/ops-manager-automation/scripts/create-env.sh
```

_Note_ you should not proceed until you have __customized__ your `${HOME}/.env` file to suit your target environment

## Register the configuration file

Run the configuration file into the current jumpbox shell session so we can make use of the variables straight away

```bash
eval $(cat ${HOME}/.env | cut -d'#' -f1 | tr '\n' ' ')
```
_Note_ repeat this step if you need to make changes to your configuration file or have to reconnect to your jumpbox.

## Enable the gcloud services APIs

```bash
gcloud services enable compute.googleapis.com && \
gcloud services enable iam.googleapis.com && \
gcloud services enable cloudresourcemanager.googleapis.com && \
gcloud services enable dns.googleapis.com && \
gcloud services enable sqladmin.googleapis.com
```

## Install some essential tools

```bash
sudo apt-get update && sudo apt-get --yes install unzip jq ruby

wget -O terraform.zip https://releases.hashicorp.com/terraform/0.11.6/terraform_0.11.6_linux_amd64.zip && \
  unzip terraform.zip && \
  sudo mv terraform /usr/local/bin
  
wget -O om https://github.com/pivotal-cf/om/releases/download/0.35.0/om-linux && \
  chmod +x om && \
  sudo mv om /usr/local/bin/
  
wget -O bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-3.0.1-linux-amd64 && \
  chmod +x bosh && \
  sudo mv bosh /usr/local/bin/
```

## Download the Terraform scripts from Pivotal Network

Check that `PCF_PIVNET_UAA_TOKEN` is set then run the following.

```bash
# the following identifiers represent The GCP Terraform scripts for PAS v2.1.1 
PRODUCT_SLUG=elastic-runtime
RELEASES_ID=76599
PRODUCT_FILE_ID=108845

PIVNET_ACCESS_TOKEN=$(curl \
  --header "Content-Type: application/json" \
  --data "{\"refresh_token\": \"${PCF_PIVNET_UAA_TOKEN}\"}" \
  "https://network.pivotal.io/api/v2/authentication/access_tokens" | \
     jq -r '.access_token')

curl \
  --location \
  --header "Authorization: Bearer ${PIVNET_ACCESS_TOKEN}" \
  --request POST \
  "https://network.pivotal.io/api/v2/products/${PRODUCT_SLUG}/releases/${RELEASES_ID}/eula_acceptance"

curl \
  --location \
  --output ${HOME}/terraforming-gcp.zip \
  --header "Authorization: Bearer ${PIVNET_ACCESS_TOKEN}" \
  "https://network.pivotal.io/api/v2/products/${PRODUCT_SLUG}/releases/${RELEASES_ID}/product_files/${PRODUCT_FILE_ID}/download"
    
unzip ${HOME}/terraforming-gcp.zip -d ${HOME}
```

## Create a gcloud services account for Terraform

From the `${HOME}/pivotal-cf-terraforming-gcp-*/` directory, perform the following

```bash
cd ${HOME}/pivotal-cf-terraforming-gcp-*/

gcloud iam service-accounts create terraform-service-account --display-name terraform

gcloud iam service-accounts keys create 'gcp_credentials.json' \
  --iam-account "terraform-service-account@${PCF_PROJECT_ID}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding ${PCF_PROJECT_ID} \
  --member "serviceAccount:terraform-service-account@${PCF_PROJECT_ID}.iam.gserviceaccount.com" \
  --role 'roles/owner'
```

## Generate a wildcard SAN certificate
```no-highlight
cat > ./${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.cnf <<-EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
[ dn ]
C=US
ST=Colorado
L=Boulder
O=PIVOTAL, INC.
OU=EDUCATION
CN = ${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
[ req_ext ]
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = *.sys.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
DNS.2 = *.login.sys.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
DNS.3 = *.uaa.sys.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
DNS.4 = *.apps.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
EOF

openssl req -x509 \
  -newkey rsa:2048 \
  -nodes \
  -keyout ${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.key \
  -out ${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.cert \
  -config ./${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.cnf
```

## Create the `terraform.tfvars` file

```bash
cat > ./terraform.tfvars <<-EOF
env_name            = "${PCF_SUBDOMAIN_NAME}"
project             = "${PCF_PROJECT_ID}"
region              = "${PCF_REGION}"
zones               = ["${PCF_AZ_1}", "${PCF_AZ_2}", "${PCF_AZ_3}"]
dns_suffix          = "${PCF_DOMAIN_NAME}"
opsman_image_url    = "https://storage.googleapis.com/${PCF_OPSMAN_IMAGE}"
buckets_location    = "US"
create_gcs_buckets  = "false"
external_database   = "false"
isolation_segment   = "false"
ssl_cert            = <<SSL_CERT
$(cat ./${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.cert)
SSL_CERT
ssl_private_key     = <<SSL_KEY
$(cat ./${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.key)
SSL_KEY
service_account_key = <<SERVICE_ACCOUNT_KEY
$(cat ./gcp_credentials.json | tr -d '\n')
SERVICE_ACCOUNT_KEY
EOF
```

## Run terraform to deploy your Ops Manager VM

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

This will take about 5 minutes to complete

## Configure bi-directional VPC Network Peering for SSH

The jumpbox has no option but to go in the `default` network but the terraform scripts create the Ops Manager VM in a custom network, 
not directly accessible from the jumpbox.  We can address this in GCP with VPC Network Peering.

```bash
gcloud compute networks peerings create default-to-${PCF_SUBDOMAIN_NAME}-pcf-network \
  --network=default \
  --peer-network=${PCF_SUBDOMAIN_NAME}-pcf-network \
  --auto-create-routes

gcloud compute networks peerings create ${PCF_SUBDOMAIN_NAME}-pcf-network-to-default \
  --network=${PCF_SUBDOMAIN_NAME}-pcf-network \
  --peer-network=default \
  --auto-create-routes
```
