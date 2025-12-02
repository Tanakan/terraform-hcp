remote_state {
  backend = "s3"
  generate = {
    path      = "backend_generated.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "iac-terraform-tfstate-${get_aws_account_id()}"
    key            = "rosa-hcp/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "iac-terraform-tfstate-lock"
  }
}
