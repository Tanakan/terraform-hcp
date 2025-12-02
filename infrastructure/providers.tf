# Backend は terragrunt.hcl で設定 (get_aws_account_id() で自動取得)

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
