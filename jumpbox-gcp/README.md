# [ops-manager-automation](../README.md) / jumpbox-gcp

## Prerequisites

On GCP:
- A pristine GCP project

## Creating a jumpbox on GCP

From within your _pristine_ GCP project, open the Cloud Shell.

![gcp_cli_launch](gcp_cli_launch.png)

From Cloud Shell, review the available zones and select an appropriate one:

```bash
gcloud compute zones list
PCF_AZ_1=CHANGE_ME_AZ_1 # e.g. us-central1-a
```
From Cloud Shell, type the following to create your jumpbox:

```bash
gcloud compute instances create "jumpbox" \
  --project "$(gcloud config get-value core/project 2> /dev/null)" \
  --zone "${PCF_AZ_1}" \
  --image "ubuntu-1604-xenial-v20180405" \
  --image-project "ubuntu-os-cloud" \
  --machine-type=f1-micro \
  --boot-disk-size "200"
```

SSH to your new jumpbox

```bash
gcloud compute ssh ubuntu@jumpbox \
  --project "$(gcloud config get-value core/project 2> /dev/null)" \
  --zone "${PCF_AZ_1}"
```

Initialize gcloud on the jumpbox

```bash
gcloud init --project "$(gcloud config get-value core/project 2> /dev/null)"
```

During the dialogue select the following options:

- Log in with a new account
- Authenticate with your personal account ("Y")
- Click the browser link and copy the verification code back into the gcloud dialogue
- Configure a default Compute Region and Zone? ("Y")
- Select the zone that matches ${PCF_AZ_1}

