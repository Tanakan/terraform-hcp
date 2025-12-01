output "iac_user_arn" {
  description = "IaC ユーザーの ARN"
  value       = aws_iam_user.iac.arn
}

output "iac_user_name" {
  description = "IaC ユーザー名"
  value       = aws_iam_user.iac.name
}

output "iac_policy_arn" {
  description = "IaC ポリシーの ARN"
  value       = aws_iam_policy.iac_rosa_hcp.arn
}

output "iac_access_key_id" {
  description = "IaC ユーザーのアクセスキー ID"
  value       = var.create_iac_access_key ? aws_iam_access_key.iac[0].id : null
  sensitive   = true
}

output "iac_secret_access_key" {
  description = "IaC ユーザーのシークレットアクセスキー"
  value       = var.create_iac_access_key ? aws_iam_access_key.iac[0].secret : null
  sensitive   = true
}

output "tfstate_bucket" {
  description = "Terraform State S3 Bucket"
  value       = aws_s3_bucket.tfstate.id
}

output "tfstate_lock_table" {
  description = "Terraform State Lock DynamoDB Table"
  value       = aws_dynamodb_table.tfstate_lock.name
}

output "next_steps" {
  description = "次のステップ"
  value       = <<-EOT

    ========================================
    Bootstrap 完了
    ========================================

    1. backend.tf を infrastructure/ に作成:

       terraform {
         backend "s3" {
           bucket         = "${aws_s3_bucket.tfstate.id}"
           key            = "terraform.tfstate"
           region         = "ap-northeast-1"
           encrypt        = true
           dynamodb_table = "${aws_dynamodb_table.tfstate_lock.name}"
         }
       }

    2. State を移行:
       cd ..
       terraform init -migrate-state

  EOT
}
