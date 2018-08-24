# [ops-manager-automation](./README.md)

## What?

A set of scripts for deploying PCF (including PAS & PKS) on GCP with automation tools at its heart.

## Why?

Because we need something to bridge the gap between:

a) doing everything manual (i.e. Ops Manager UI)

b) doing everything automated (i.e. [PCF Pipelines](https://github.com/pivotal-cf/pcf-pipelines))

As per PCF Pipelines, these scripts use both [Om](https://github.com/pivotal-cf/om) and [PivNet](https://github.com/pivotal-cf/pivnet-cli) CLIs.  The difference is we don't encase all that logic behind [Concourse](https://concourse-ci.org/), which makes these scripts a great educational tool with added transparency and flexibility.

## How?

Like this ...

## Prerequisites

You need to do some important groundwork to get moving so make sure you follow these steps first.

You will need:
- A production-strength domain name registrar (e.g. AWS Route 53 or Google Domains)
- A registered domain name (e.g. pivotaledu.io)
- An active Pivotal Network account.  Sign up [here](https://account.run.pivotal.io/z/uaa/sign-up)
- An active GCP account.  Sign up [here](https://console.cloud.google.com/freetrial)
- A pristine GCP project
- The following CLI tools installed:
  - [Embedded Ruby (erb)](https://www.ruby-lang.org/en/documentation/installation)
  - [om](https://github.com/pivotal-cf/om/releases)
  - [pivnet](https://github.com/pivotal-cf/pivnet-cli/releases)
  - [jq](https://github.com/stedolan/jq/releases)

## First Steps

- [Step 1](./jumpbox-gcp/README.md) - Establish an SSH session on a pristine Ubuntu jumpbox, authenticated with `gcloud auth login`
- [Step 2](./ops-manager-gcp/README.md) - Install a fresh instance of Ops Manager

Now you can continue to learn about the scripts or jump right in with [some examples](#putting-it-all-together) ...

## Task Scripts

Let's change into the directory of our cloned repo to keep our task 
script commands short:

```no-highlight
cd ~/ops-manager-automation
```

### `create-env.sh` (covered in Prerequisites)

We always start here.  This is the script we used from the jumpbox when 
installing the Ops Manager.  It creates a template for our configuration 
at `~/.env` which we must customize before installing the Ops Manager 
or running any of the other task scripts.

Example usage:

```no-highlight
./scripts/create-env.sh
```

### `mk-ssl-cert-key.sh` (covered in Prerequisites)

Customized from the Pivotal Toolsmiths original, this script uses the 
`openssl` CLI tool to generate self-signed certificate and key files for 
use with this installation.  Generated files are deposited in the current 
working directory where they remain available for use by subsequent tile 
configuration scripts.

Example usage:

```no-highlight
./scripts/mk-ssl-cert-key.sh
```

### `configure-authentication.sh`

This script is designed to be used against a **freshly installed** Ops 
Manager installation which has not yet had authentication configured.  
The DNS configuration **must** have fully propagated such that the 
installation is accessible via its FQDN.  This script will select 
`Internal Authentication` and configure an `admin` account with the 
password provided in `vars.txt`.  **Note** for simplicity, the 
passphrase will always be configured to match the `admin` password.

Example usage:

```no-highlight
./scripts/configure-authentication.sh
```

### `configure-director-gcp.sh`

This script should be used against an **freshly authenticated** Ops 
Manager installation to turn the Ops Manager Director tile from "orange" 
to "green".  Please inspect the `templates/director` directory to gain a 
technical appreciation for how this is achieved.

Example usage:

```no-highlight
IMPORTED_VERSION=2.2.1 ./scripts/configure-director-gcp.sh
```

### `apply-changes-director.sh` and `apply-changes.sh`

Does exactly what it says ... clicks the big blue button!

**Note** in the case of the former script, it will only `Apply Changes` 
related to the Ops Manager Director tile.

Example usage:

```no-highlight
./scripts/apply-changes-director.sh
# or
./scripts/apply-changes.sh
```

### `download-product.sh`

This script fetches products and stemcells from PivNet and stores them 
in a directory structure beneath `downloads`.  As these files can be 
quite large, we recommend you only run this script from a Jumpbox VM 
alongside your targeted Ops Manager.  For a large products like PAS, you 
can expect this to take ~5 mins.

Example usage:

```no-highlight
PRODUCT_NAME="Pivotal Application Service (formerly Elastic Runtime)" \
PRODUCT_VERSION="2.2.2" \
DOWNLOAD_REGEX="Small Footprint PAS" \
  ./scripts/download-product.sh
```

### `import-product.sh`

This script takes **previously downloaded** products and stemcells from 
the directory structure beneath `downloads` and imports them to an Ops 
Manager instance.  The script will attempt to resolve any missing 
products by internally invoking `download-product.sh` as appropriate.  
We recommend you only run this script from a Jumpbox VM alongside your 
targeted Ops Manager.  For a large product like PAS, you can expect this 
to take ~15 mins.

Example usage:

```no-highlight
PRODUCT_NAME="Pivotal Application Service (formerly Elastic Runtime)" \
PRODUCT_VERSION="2.2.2" \
DOWNLOAD_REGEX="Small Footprint PAS" \
  ./scripts/import-product.sh
```

### `list-imports.sh`

Shows which products have been imported and are ready to be staged.  
Useful when establishing correct terms for `IMPORTED_NAME` and 
`IMPORTED_VERSION` variables.

Example usage:

```no-highlight
./scripts/list-imports.sh
```

### `stage-product.sh`

Whenever we click the `+` (plus) button next to an imported product in 
the Ops Manager we'll see a new or updated tile in the installation 
dashboard.  That procedure is referred to as 
**staging an imported product**.  This script automates that button 
click.

Example usage:

```no-highlight
IMPORTED_NAME="cf" IMPORTED_VERSION="2.2.2" ./scripts/stage-product.sh
```

### `configure-product.sh`

The intention of this script is to turn any given tile from "orange" to 
"green".  Please inspect the `templates/cf` and `templates/p-healthwatch` 
directories to gain a technical appreciation for how this is achieved.

Example usage:

```no-highlight
IMPORTED_NAME="cf" IMPORTED_VERSION="2.2.2" ./scripts/configure-product.sh
```

_Note_ you may choose to run `apply-changes.sh` once after each call to 
`configure-product.sh` but it's often more time-efficient to configure 
multiple products and apply all changes as a single batch.

# Putting it all together

There now follows the sequence of commands required to automate a 
configuration/deployment of the Ops Manager Director, Pivotal Application 
Service (PAS - Small Footprint) and a handful of common products.  This 
assumes a valid `~/.env` file and a fresh install of the Ops Manager, 
the version of which is compatible with the target PAS - in this case 
v2.2.x.  These steps incorporate both a PivNet download and an Ops 
Manager import which could take a long time to complete.  As the script 
incorporates large downloads/imports, we recommend you only run this 
script from a Jumpbox VM alongside your targeted Ops Manager.

```no-highlight
# prepare director
./scripts/configure-authentication.sh
IMPORTED_VERSION=2.2.2 ./scripts/configure-director-gcp.sh

# create certificate and key (if necessary)
./scripts/mk-ssl-cert-key.sh

# import required stemcells
PRODUCT_NAME="Stemcells for PCF" PRODUCT_VERSION="3541.34" DOWNLOAD_REGEX="Ubuntu Trusty Stemcell for Google Cloud Platform" ./scripts/import-product.sh
PRODUCT_NAME="Stemcells for PCF" PRODUCT_VERSION="3468.51" DOWNLOAD_REGEX="Ubuntu Trusty Stemcell for Google Cloud Platform" ./scripts/import-product.sh
PRODUCT_NAME="Stemcells for PCF" PRODUCT_VERSION="3586.27" DOWNLOAD_REGEX="google" ./scripts/import-product.sh

# install Small Footprint PAS
PRODUCT_NAME="Pivotal Application Service (formerly Elastic Runtime)" PRODUCT_VERSION="2.2.2" DOWNLOAD_REGEX="Small Footprint PAS" ./scripts/import-product.sh
IMPORTED_NAME="cf" IMPORTED_VERSION="2.2.2" ./scripts/stage-product.sh
IMPORTED_NAME="cf" IMPORTED_VERSION="2.2.2" ./scripts/configure-product.sh

# install PKS
PRODUCT_NAME="Pivotal Container Service (PKS)" PRODUCT_VERSION="1.1.4" DOWNLOAD_REGEX="pivotal-container-service" ./scripts/import-product.sh
IMPORTED_NAME="pivotal-container-service" IMPORTED_VERSION="1.1.4-build.5" ./scripts/stage-product.sh
IMPORTED_NAME="pivotal-container-service" IMPORTED_VERSION="1.1.4-build.5" ./scripts/configure-product.sh

# install MySQL
PRODUCT_NAME="MySQL for PCF" PRODUCT_VERSION="2.3.1" DOWNLOAD_REGEX="MySQL for PCF" ./scripts/import-product.sh
IMPORTED_NAME="pivotal-mysql" IMPORTED_VERSION="2.3.1-build.11" ./scripts/stage-product.sh
IMPORTED_NAME="pivotal-mysql" IMPORTED_VERSION="2.3.1-build.11" ./scripts/configure-product.sh

# install Healthwatch
PRODUCT_NAME="Pivotal Cloud Foundry Healthwatch" PRODUCT_VERSION="1.2.3" DOWNLOAD_REGEX="PCF Healthwatch$" ./scripts/import-product.sh
IMPORTED_NAME="p-healthwatch" IMPORTED_VERSION="1.2.3-build.19" ./scripts/stage-product.sh
IMPORTED_NAME="p-healthwatch" IMPORTED_VERSION="1.2.3-build.19" ./scripts/configure-product.sh

# install RabbitMQ
PRODUCT_NAME="RabbitMQ for PCF" PRODUCT_VERSION="1.12.7" DOWNLOAD_REGEX="RabbitMQ for PCF$" ./scripts/import-product.sh
IMPORTED_NAME="p-rabbitmq" IMPORTED_VERSION="1.12.7" ./scripts/stage-product.sh
IMPORTED_NAME="p-rabbitmq" IMPORTED_VERSION="1.12.7" ./scripts/configure-product.sh

# install Redis
PRODUCT_NAME="Redis for PCF" PRODUCT_VERSION="1.12.1" DOWNLOAD_REGEX="Redis for PCF$" ./scripts/import-product.sh
IMPORTED_NAME="p-redis" IMPORTED_VERSION="1.12.1" ./scripts/stage-product.sh
IMPORTED_NAME="p-redis" IMPORTED_VERSION="1.12.1" ./scripts/configure-product.sh

# install SSO
PRODUCT_NAME="Single Sign-On for PCF" PRODUCT_VERSION="1.6.0" DOWNLOAD_REGEX="Pivotal_Single_Sign-On_Service" ./scripts/import-product.sh
IMPORTED_NAME="Pivotal_Single_Sign-On_Service" IMPORTED_VERSION="1.6.0" ./scripts/stage-product.sh
IMPORTED_NAME="Pivotal_Single_Sign-On_Service" IMPORTED_VERSION="1.6.0" ./scripts/configure-product.sh

# install AWS Broker
PRODUCT_NAME="Pivotal Cloud Foundry Service Broker for AWS" PRODUCT_VERSION="1.4.8" DOWNLOAD_REGEX="Service Broker for AWS" ./scripts/import-product.sh
IMPORTED_NAME="aws-services" IMPORTED_VERSION="1.4.8" ./scripts/stage-product.sh
IMPORTED_NAME="aws-services" IMPORTED_VERSION="1.4.8" PCF_AWS_ACCESS_KEY_ID="SOME_ID" PCF_AWS_SECRET_ACCESS_KEY="SOME_SECRET" ./scripts/configure-product.sh

# install SCS
PRODUCT_NAME="Spring Cloud Services for PCF" PRODUCT_VERSION="1.5.6" DOWNLOAD_REGEX="Spring Cloud Services Product Installer" ./scripts/import-product.sh
IMPORTED_NAME="p-spring-cloud-services" IMPORTED_VERSION="1.5.6" ./scripts/stage-product.sh
IMPORTED_NAME="p-spring-cloud-services" IMPORTED_VERSION="1.5.6" ./scripts/configure-product.sh

# apply changes for director first, then products
./scripts/apply-changes-director.sh
./scripts/apply-changes.sh
```
