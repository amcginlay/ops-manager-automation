# Step 1 - [ops-manager-automation](../README.md) / jumpbox-gcp

## Prerequisites

On GCP:
- A pristine GCP project

## Creating a jumpbox on GCP

From within your _pristine_ GCP project, open the Cloud Shell.

![gcp_cli_launch](gcp_cli_launch.png)

From your Cloud Shell session, execute the following `gcloud` command 
to create your jumpbox.

If you would prefer to create and/or connect to your jumpbox from your 
local machine, you must first use `gcloud auth login` and you should 
add the `--project [GCP_PROJECT_ID]` switch to the `gcloud compute` 
commands in this section.

```bash
gcloud compute instances create "jbox-pcf" \
  --image-project "ubuntu-os-cloud" \
  --image-family "ubuntu-1804-lts" \
  --boot-disk-size "200" \
  --machine-type=f1-micro \
  --zone us-central1-a
```

SSH to your new jumpbox

```bash
gcloud compute ssh ubuntu@jbox-pcf --zone us-central1-a
```

Initialize the `gcloud` CLI on the jumpbox:

```bash
gcloud auth login
```

Follow the on-screen prompts. We will need to copy-paste the URL from 
our `gcloud` CLI jumpbox session into a local browser in order to select 
the account you have registered for use with Google Cloud. Additionally, 
you'll need copy-paste the verification code back into your jumpbox 
session to complete the login sequence.

# Next Step

- [Step 2](../ops-manager-gcp/README.md) - Install a fresh instance of Ops Manager
