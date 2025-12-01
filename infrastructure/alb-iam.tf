#------------------------------------------------------------------------------
# ALB Controller IAM Role (for AWS Load Balancer Operator)
#------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# クラスター作成後にOIDC情報を取得
data "rhcs_cluster_rosa_hcp" "cluster" {
  id = module.rosa_hcp.cluster_id
}

locals {
  # ROSA HCP OIDC endpoint URL from cluster data source
  oidc_endpoint_url = data.rhcs_cluster_rosa_hcp.cluster.sts.oidc_endpoint_url
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(local.oidc_endpoint_url, "https://", "")}"
  oidc_provider_url = replace(local.oidc_endpoint_url, "https://", "")
}

resource "aws_iam_policy" "alb_controller" {
  name   = "${var.cluster_name}-alb-controller-policy"
  policy = file("${path.module}/policies/alb-controller-policy.json")
}

resource "aws_iam_role" "alb_controller" {
  name = "${var.cluster_name}-alb-controller"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = local.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider_url}:sub" = "system:serviceaccount:aws-load-balancer-operator:aws-load-balancer-controller-cluster"
        }
      }
    }]
  })

  tags = {
    Name = "${var.cluster_name}-alb-controller"
  }
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}
