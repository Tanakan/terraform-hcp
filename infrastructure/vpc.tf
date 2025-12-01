#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------
resource "aws_vpc" "rosa" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

#------------------------------------------------------------------------------
# Internet Gateway
#------------------------------------------------------------------------------
resource "aws_internet_gateway" "rosa" {
  vpc_id = aws_vpc.rosa.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

#------------------------------------------------------------------------------
# Public Subnets
#------------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.rosa.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.cluster_name}-public-${var.availability_zones[count.index]}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

#------------------------------------------------------------------------------
# Private Subnets
#------------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.rosa.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                        = "${var.cluster_name}-private-${var.availability_zones[count.index]}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

#------------------------------------------------------------------------------
# NAT Gateway (各AZに1つ)
#------------------------------------------------------------------------------
resource "aws_eip" "nat" {
  count  = length(var.availability_zones)
  domain = "vpc"

  tags = {
    Name = "${var.cluster_name}-nat-eip-${var.availability_zones[count.index]}"
  }

  depends_on = [aws_internet_gateway.rosa]
}

resource "aws_nat_gateway" "rosa" {
  count = length(var.availability_zones)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.cluster_name}-nat-${var.availability_zones[count.index]}"
  }

  depends_on = [aws_internet_gateway.rosa]
}

#------------------------------------------------------------------------------
# Route Tables
#------------------------------------------------------------------------------
# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.rosa.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rosa.id
  }

  tags = {
    Name = "${var.cluster_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables (各AZごと)
resource "aws_route_table" "private" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.rosa.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.rosa[count.index].id
  }

  tags = {
    Name = "${var.cluster_name}-private-rt-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

#------------------------------------------------------------------------------
# Security Group Rules for NLB NodePort Access
# ROSA creates worker security groups automatically, but we need to add
# rules to allow NLB health checks and traffic to NodePort range
#------------------------------------------------------------------------------

# Data source to find the ROSA default security group
# ROSA HCP creates a security group named "<cluster-id>-default-sg"
data "aws_security_group" "rosa_worker" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.rosa.id]
  }

  filter {
    name   = "group-name"
    values = ["*-default-sg"]
  }

  depends_on = [module.rosa_hcp]
}

# Allow NodePort TCP traffic from VPC CIDR (for internal NLB health checks)
resource "aws_security_group_rule" "nodeport_vpc" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = data.aws_security_group.rosa_worker.id
  description       = "Allow NodePort access from VPC for NLB health checks"
}

# Allow NodePort TCP traffic from internet (for internet-facing NLB)
resource "aws_security_group_rule" "nodeport_internet" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.rosa_worker.id
  description       = "Allow NodePort access from internet for NLB"
}
