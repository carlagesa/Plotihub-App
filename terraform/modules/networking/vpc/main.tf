terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# --- Subnets ---
# We create private subnets to house our database, which should not be accessible from the internet.
# We create them in different Availability Zones (AZs) for high availability.

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 0) # e.g., 10.0.0.0/24
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.environment}-private-subnet-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 1) # e.g., 10.0.1.0/24
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.environment}-private-subnet-b"
  }
}