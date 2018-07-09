# [ops-manager-automation](../README.md) / jumpbox-gcp

## Prerequisites

On GCP:
- A pristine GCP project

## Creating a jumpbox on GCP

From within your _pristine_ GCP project, open the Cloud Shell.

![gcp_cli_launch](gcp_cli_launch.png)

From your Cloud Shell session, execute the following to create your 
jumpbox:

```bash
gcloud compute instances create "jumpbox" \
  --image-family "ubuntu-1804-lts" \
  --image-project "ubuntu-os-cloud" \
  --boot-disk-size "200" \
  --machine-type=f1-micro \
  --zone us-central1-a
```

SSH to your new jumpbox

```bash
gcloud compute ssh ubuntu@jumpbox --zone us-central1-a
```

Initialize the gcloud CLI on the jumpbox:

```bash
gcloud auth login
```

Follow the on-screen prompts. We will need to copy-paste the URL into a 
local browser in order to select the account you have registered for use 
with Google Cloud. Additionally, you'll need copy-paste the verification 
code back into your jumpbox session to complete the login sequence.