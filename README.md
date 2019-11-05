# flask-pg-app
[![Build Status](https://cloud.drone.io/api/badges/helhindi/flask-pg-app/status.svg)](https://cloud.drone.io/helhindi/flask-pg-app)

## Introduction
A sample web + postgresql backend application.

**Note:** The instructions assume an OSX machine with `brew` installed.

## Getting Started

#### Clone repo & install pre-req tools:
From an OSX machine's Terminal; launch the following commands:

#### Install `brew`:
* `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`


#### Clone repo:
* `git clone https://github.com/helhindi/flask-pg-app.git && cd flask-pg-app`
* `brew bundle --verbose`

#### Initialise Terraform GCP vars:
* `export TF_VAR_project="$(gcloud config list \`
  `--format 'value(core.project)'`
)"`
* `export TF_VAR_region="europe-west2"`

Now specify an administrative account `user=admin` and set a random password: 
* `export TF_VAR_user="admin"`
* `export TF_VAR_password="m8XBWryuWEJ238ew"`

## Initialise and create environment
* terraform init

* terraform plan

and if confident (this will spin up a GKE cluster on Gcloud);
* terraform apply
