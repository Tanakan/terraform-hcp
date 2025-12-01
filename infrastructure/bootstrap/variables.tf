variable "aws_region" {
  description = "AWS リージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "iac_user_name" {
  description = "IaC 用 IAM ユーザー名"
  type        = string
  default     = "iac-terraform"
}

variable "create_iac_access_key" {
  description = "IaC ユーザーのアクセスキーを作成するか"
  type        = bool
  default     = true
}
