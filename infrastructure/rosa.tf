#------------------------------------------------------------------------------
# ROSA HCP Cluster
#------------------------------------------------------------------------------
module "rosa_hcp" {
  source  = "terraform-redhat/rosa-hcp/rhcs"
  version = "1.6.2"

  cluster_name           = var.cluster_name
  openshift_version      = var.openshift_version
  machine_cidr           = var.vpc_cidr
  aws_subnet_ids         = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)
  aws_availability_zones = var.availability_zones
  replicas               = var.replicas
  private                = var.private_cluster
  pod_cidr               = var.pod_cidr
  service_cidr           = var.service_cidr

  # Wait for cluster creation (default timeout is too short)
  wait_for_create_complete            = true
  wait_for_std_compute_nodes_complete = true

  # AWS Account IAM Roles
  create_account_roles = true
  account_role_prefix  = "${var.cluster_name}-account"

  # OIDC Configuration
  create_oidc = true

  # Operator Roles
  create_operator_roles = true
  operator_role_prefix  = "${var.cluster_name}-operator"

  # Tags - 既存クラスタでは変更不可のため削除
  # tags = var.default_tags

  depends_on = [
    aws_vpc.rosa,
    aws_subnet.private,
    aws_subnet.public,
    aws_nat_gateway.rosa
  ]
}

# Google Workspace IDP は後で設定 (rhcs_identity_provider リソースを使用)
