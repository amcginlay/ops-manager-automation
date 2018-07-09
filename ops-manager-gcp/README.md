# [ops-manager-automation](../README.md) / ops-manager-gcp

## Prerequisites

On GCP:
- A pristine GCP project
- An SSH session on a pristine Ubuntu jumpbox with `gcloud` initialized ([click here](../jumpbox-gcp/README.md))

## SSH to your jumpbox (if necessary)

From Cloud Shell:

```bash
gcloud compute ssh ubuntu@jumpbox --zone us-central1-a
```

## Clone _this_ repo

From the jumpbox:

```bash
git clone https://github.com/amcginlay/ops-manager-automation.git ~/ops-manager-automation

# [or clone with SSH]
git clone git@github.com:amcginlay/ops-manager-automation.git ~/ops-manager-automation
```

## Create a configuration file

From your jumpbox, create a `~/.env` configuration file to describe the 
specifics of your environment.

```bash
~/ops-manager-automation/scripts/create-env.sh
```

_Note_ you should not proceed until you have __customized__ your 
`~/.env` file to suit your target environment

## Register the configuration file

Now that we have the .env file with our critical variables, we need to 
ensure that these get set into the shell, both now and every subsequent 
time the ubuntu user connects to the jumpbox.

```bash
source ~/.env
echo "source ~/.env" >> ~/.bashrc
```

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

wget -O terraform.zip https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip && \
  unzip terraform.zip && \
  sudo mv terraform /usr/local/bin
  
wget -O om https://github.com/pivotal-cf/om/releases/download/0.38.0/om-linux && \
  chmod +x om && \
  sudo mv om /usr/local/bin/
  
wget -O bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-4.0.1-linux-amd64 && \
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
  --fail \
  --header "Content-Type: application/json" \
  --data "{\"refresh_token\": \"${PCF_PIVNET_UAA_TOKEN}\"}" \
  "https://network.pivotal.io/api/v2/authentication/access_tokens" | \
     jq -r '.access_token')

curl \
  --fail \
  --location \
  --header "Authorization: Bearer ${PIVNET_ACCESS_TOKEN}" \
  --request POST \
  "https://network.pivotal.io/api/v2/products/${PRODUCT_SLUG}/releases/${RELEASES_ID}/eula_acceptance"

curl \
  --fail \
  --location \
  --output ${HOME}/terraforming-gcp.zip \
  --header "Authorization: Bearer ${PIVNET_ACCESS_TOKEN}" \
  "https://network.pivotal.io/api/v2/products/${PRODUCT_SLUG}/releases/${RELEASES_ID}/product_files/${PRODUCT_FILE_ID}/download"
    
unzip ~/terraforming-gcp.zip -d ${HOME}
```

## Create a gcloud services account for Terraform

From the `~/pivotal-cf-terraforming-gcp-*/` directory, perform the following

```bash
PCF_PROJECT_ID=$(gcloud config get-value core/project)

cd ~/pivotal-cf-terraforming-gcp-*/

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
region              = "us-central1"
zones               = ["us-central1-b", "us-central1-a", "us-central1-c"]
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
$(cat ./gcp_credentials.json)
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
