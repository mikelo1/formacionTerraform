#/bin/bash

terraform init
terraform validate --var-file=variables.tfvars
terraform plan --var-file=variables.tfvars
