data "aws_availability_zones" "this" {
  state = "available"
}

# carve four /20s out of the VPC /16 (change sizes as you like)
# first two for app, next two for db subnets
locals {
  azs = slice(data.aws_availability_zones.this.names, 0, 2)

  app_subnets = [
    cidrsubnet(var.vpc_cidr, 4, 0),
    cidrsubnet(var.vpc_cidr, 4, 1)
  ]

  db_subnets = [
    cidrsubnet(var.vpc_cidr, 4, 2),
    cidrsubnet(var.vpc_cidr, 4, 3)
  ]
}

module "network_primary" {
  source = "./modules/network"

  name              = "${local.name}-primary"
  cidr_block        = var.vpc_cidr
  azs               = local.azs
  private_app_cidrs = local.app_subnets
  private_db_cidrs  = local.db_subnets
  db_port           = var.db_port

  tags = {
    Project = var.project
    Env     = var.env
  }
}
