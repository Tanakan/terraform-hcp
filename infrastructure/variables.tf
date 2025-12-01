#------------------------------------------------------------------------------
# General
#------------------------------------------------------------------------------
variable "cluster_name" {
  description = "ROSA HCP クラスター名"
  type        = string
}

variable "aws_region" {
  description = "AWS リージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "default_tags" {
  description = "全AWSリソースに適用するデフォルトタグ"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Project   = "rosa-hcp"
  }
}

#------------------------------------------------------------------------------
# Network
#------------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "VPC CIDR ブロック"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "使用するアベイラビリティゾーン"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

variable "private_subnet_cidrs" {
  description = "プライベートサブネット CIDR (ROSA ノード用)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "パブリックサブネット CIDR (NAT Gateway用)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

#------------------------------------------------------------------------------
# ROSA HCP Cluster
#------------------------------------------------------------------------------
variable "openshift_version" {
  description = "OpenShift バージョン"
  type        = string
  default     = "4.16.52"
}

variable "replicas" {
  description = "ワーカーノード数 (プライベートサブネット数の倍数にする必要あり)"
  type        = number
  default     = 3
}

variable "compute_machine_type" {
  description = "ワーカーノードのインスタンスタイプ"
  type        = string
  default     = "m5.xlarge"
}

variable "private_cluster" {
  description = "プライベートクラスターとして作成するか"
  type        = bool
  default     = false
}

variable "pod_cidr" {
  description = "Pod CIDR"
  type        = string
  default     = "10.128.0.0/14"
}

variable "service_cidr" {
  description = "Service CIDR"
  type        = string
  default     = "172.30.0.0/16"
}

#------------------------------------------------------------------------------
# Admin User (初期セットアップ用、本番ではOIDCを使用)
#------------------------------------------------------------------------------
variable "create_admin_user" {
  description = "クラスター管理者ユーザーを作成するか"
  type        = bool
  default     = true
}

variable "admin_username" {
  description = "管理者ユーザー名"
  type        = string
  default     = "cluster-admin"
}

variable "admin_password" {
  description = "管理者パスワード"
  type        = string
  sensitive   = true
  default     = null
}

#------------------------------------------------------------------------------
# Google Workspace OIDC
#------------------------------------------------------------------------------
variable "google_idp_enabled" {
  description = "Google Workspace OIDC を有効にするか"
  type        = bool
  default     = true
}

variable "google_idp_name" {
  description = "Google IDP の表示名"
  type        = string
  default     = "Google"
}

variable "google_client_id" {
  description = "Google OAuth Client ID"
  type        = string
  default     = ""
}

variable "google_client_secret" {
  description = "Google OAuth Client Secret"
  type        = string
  sensitive   = true
  default     = ""
}

variable "google_hosted_domain" {
  description = "Google Workspace ドメイン (例: example.com)"
  type        = string
  default     = ""
}
