# Configure the AWS provider for the primary region
provider "aws" {
  region = var.primary_region
  alias  = "primary" # An alias to refer to this specific provider
}

# Configure the AWS provider for the secondary region
provider "aws" {
  region = var.secondary_region
  alias  = "secondary" # A different alias for the other provider
}

# --- Networking Layer ---

# Deploy the VPC in the primary region (us-east-1)
module "vpc_primary" {
  source = "../../modules/networking/vpc"

  # Tell this module to use the "primary" provider configuration
  providers = {
    aws = aws.primary
  }

  aws_region  = var.primary_region
  vpc_cidr    = "10.0.0.0/16"
  environment = "dev"
}

# Deploy the VPC in the secondary region (us-east-2)
module "vpc_secondary" {
  source = "../../modules/networking/vpc"

  # Tell this module to use the "secondary" provider configuration
  providers = {
    aws = aws.secondary
  }

  aws_region  = var.secondary_region
  vpc_cidr    = "10.1.0.0/16"
  environment = "dev"
}

# --- Data Layer ---

# Call the secrets module to create and replicate our database password.
# This module uses the primary provider by default.
module "secrets" {
  source = "../../modules/data/secrets"

  environment      = "dev"
  secondary_region = var.secondary_region
}

# Call the aurora module to deploy our multi-region database.
# This module is special because it needs to create resources in BOTH regions.
# We pass both provider aliases into it.
module "aurora_global" {
  source = "../../modules/data/aurora-global"

  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }

  environment = "dev"

  # Wire in the outputs from our VPC modules.
  primary_vpc_id       = module.vpc_primary.vpc_id
  primary_subnet_ids   = module.vpc_primary.private_subnet_ids
  secondary_subnet_ids = module.vpc_secondary.private_subnet_ids

  # Wire in the secret ARN from our secrets module.
  db_credentials_secret_arn = module.secrets.db_credentials_secret_arn

  # This explicit dependency ensures that the VPCs are fully created
  # before the database module attempts to use them.
  depends_on = [
    module.vpc_primary,
    module.vpc_secondary
  ]
}