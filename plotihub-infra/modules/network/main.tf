terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}

locals { tags = var.tags }

# VPC + subnets (no NAT; we'll use VPC endpoints to keep Lambdas private/cost-efficient)
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(local.tags, { Name = var.name })
}

# Route tables (one per subnet set)
resource "aws_subnet" "app" {
  for_each                = toset(var.azs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_app_cidrs[index(var.azs, each.key)]
  availability_zone       = each.key
  map_public_ip_on_launch = false
  tags                    = merge(local.tags, { Name = "${var.name}-app-${each.key}", Tier = "app" })
}

resource "aws_subnet" "db" {
  for_each                = toset(var.azs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_db_cidrs[index(var.azs, each.key)]
  availability_zone       = each.key
  map_public_ip_on_launch = false
  tags                    = merge(local.tags, { Name = "${var.name}-db-${each.key}", Tier = "db" })
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.tags, { Name = "${var.name}-rt-app" })
}
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.tags, { Name = "${var.name}-rt-db" })
}

resource "aws_route_table_association" "app" {
  for_each       = aws_subnet.app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.app.id
}
resource "aws_route_table_association" "db" {
  for_each       = aws_subnet.db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.db.id
}

# Security groups
resource "aws_security_group" "lambda" {
  name        = "${var.name}-sg-lambda"
  description = "Lambda egress and DB access"
  vpc_id      = aws_vpc.this.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # optional; we will rely on VPC endpoints; keep open for now
  }
  tags = merge(local.tags, { Name = "${var.name}-sg-lambda" })
}

resource "aws_security_group" "rds_proxy" {
  name        = "${var.name}-sg-rds-proxy"
  description = "Allow DB traffic from Lambda"
  vpc_id      = aws_vpc.this.id
  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda.id]
    description     = "Lambda to RDS Proxy"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${var.name}-sg-rds-proxy" })
}

resource "aws_security_group" "aurora" {
  name        = "${var.name}-sg-aurora"
  description = "Allow DB traffic from RDS Proxy"
  vpc_id      = aws_vpc.this.id
  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.rds_proxy.id]
    description     = "RDS Proxy to Aurora"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${var.name}-sg-aurora" })
}

# VPC Endpoint SG (strict: only from Lambda SG)
resource "aws_security_group" "vpce" {
  name        = "${var.name}-sg-vpce"
  description = "Allow interface endpoints from Lambda subnets"
  vpc_id      = aws_vpc.this.id
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda.id]
    description     = "HTTPS from Lambda"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${var.name}-sg-vpce" })
}

# Interface VPC Endpoints so Lambdas stay private (no NAT needed)
locals {
  interface_services = [
    "com.amazonaws.${data.aws_region.current.name}.secretsmanager",
    "com.amazonaws.${data.aws_region.current.name}.logs",
    "com.amazonaws.${data.aws_region.current.name}.kms"
  ]
}

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "endpoints" {
  for_each            = toset(local.interface_services)
  vpc_id              = aws_vpc.this.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpce.id]
  subnet_ids          = [for s in aws_subnet.app : s.id]

  tags = merge(local.tags, { Name = "${var.name}-vpce-${replace(each.value, "/.*\\./", "")}" })
}
