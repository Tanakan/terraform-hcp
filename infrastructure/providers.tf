#------------------------------------------------------------------------------
# Terraform Backend (S3)
#------------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket         = "iac-terraform-tfstate-195275636486"
    key            = "rosa-hcp/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "iac-terraform-tfstate-lock"
  }
}

#------------------------------------------------------------------------------
# Providers
#------------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}

# RHCS_TOKEN 環境変数から自動取得
# export RHCS_TOKEN=$(rosa token)
# または
# export RHCS_TOKEN="https://console.redhat.com/openshift/token から取得"
provider "rhcs" {}
