#------------------------------------------------------------------------------
# IaC 用 IAM ユーザー
# Terraform 実行用の専用ユーザー (ROSA HCP 構築の最小権限)
#------------------------------------------------------------------------------

resource "aws_iam_user" "iac" {
  name = var.iac_user_name
  path = "/iac/"

  tags = {
    Name    = var.iac_user_name
    Purpose = "Infrastructure as Code"
  }
}

#------------------------------------------------------------------------------
# ROSA HCP 構築用の最小権限ポリシー
#------------------------------------------------------------------------------
resource "aws_iam_policy" "iac_rosa_hcp" {
  name        = "${var.iac_user_name}-rosa-hcp"
  description = "Minimum permissions for Terraform to create ROSA HCP cluster"
  path        = "/iac/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "IAMPermissions"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:GetUser",
          "iam:GetUserPolicy",
          "iam:ListRoleTags",
          "iam:ListPolicyTags",
          "iam:ListRolePolicies",
          "iam:ListPolicyVersions",
          "iam:ListAttachedRolePolicies",
          "iam:ListAttachedUserPolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:ListEntitiesForPolicy",
          "iam:ListAccessKeys",
          "iam:CreateRole",
          "iam:CreatePolicy",
          "iam:CreatePolicyVersion",
          "iam:CreateOpenIDConnectProvider",
          "iam:UpdateRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:UpdateOpenIDConnectProviderThumbprint",
          "iam:DeleteRole",
          "iam:DeletePolicy",
          "iam:DeletePolicyVersion",
          "iam:DeleteInstanceProfile",
          "iam:DeleteOpenIDConnectProvider",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:TagRole",
          "iam:TagPolicy",
          "iam:TagOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:PassRole",
          "iam:CreateInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:UntagRole",
          "iam:UntagPolicy",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3StatePermissions"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.tfstate.arn,
          "${aws_s3_bucket.tfstate.arn}/*"
        ]
      },
      {
        Sid    = "DynamoDBLockPermissions"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.tfstate_lock.arn
      },
      {
        Sid    = "SecretsManagerPermissions"
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:CreateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:DeleteSecret",
          "secretsmanager:TagResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "EC2Permissions"
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcAttribute",
          "ec2:ModifyVpcAttribute",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:DescribeSubnets",
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:DescribeInternetGateways",
          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",
          "ec2:DescribeNatGateways",
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:DescribeAddresses",
          "ec2:DescribeAddressesAttribute",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:DescribeRouteTables",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeTags",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSecurityGroups",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DescribeNetworkAcls",
          "ec2:ModifySubnetAttribute",
          "ec2:DisassociateAddress",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.iac_user_name}-rosa-hcp"
  }
}

#------------------------------------------------------------------------------
# ポリシーアタッチ
#------------------------------------------------------------------------------
resource "aws_iam_user_policy_attachment" "iac_rosa_hcp" {
  user       = aws_iam_user.iac.name
  policy_arn = aws_iam_policy.iac_rosa_hcp.arn
}

#------------------------------------------------------------------------------
# アクセスキー
#------------------------------------------------------------------------------
resource "aws_iam_access_key" "iac" {
  count = var.create_iac_access_key ? 1 : 0

  user = aws_iam_user.iac.name
}
