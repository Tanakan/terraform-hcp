#------------------------------------------------------------------------------
# VPC Outputs
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.rosa.id
}

output "private_subnet_ids" {
  description = "プライベートサブネット ID"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "パブリックサブネット ID"
  value       = aws_subnet.public[*].id
}

#------------------------------------------------------------------------------
# ROSA HCP Cluster Outputs
#------------------------------------------------------------------------------
output "cluster_id" {
  description = "ROSA HCP クラスター ID"
  value       = module.rosa_hcp.cluster_id
}
