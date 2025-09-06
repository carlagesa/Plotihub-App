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

  #Pass the new output from the secrets module to the new input of the aurora_global module
  db_credentials_map = module.secrets.db_credentials_map

  # This explicit dependency ensures that the VPCs are fully created
  # before the database module attempts to use them.
  depends_on = [
    module.vpc_primary,
    module.vpc_secondary
  ]
}

#Security Groups for Primary Region ---
module "security_groups_primary" {
  source = "../../modules/networking/security-groups"
  providers = {
    aws = aws.primary
  }

  environment = "dev"
  vpc_id      = module.vpc_primary.vpc_id
}

#Security Groups for Secondary Region ---
module "security_groups_secondary" {
  source = "../../modules/networking/security-groups"
  providers = {
    aws = aws.secondary
  }

  environment = "dev"
  vpc_id      = module.vpc_secondary.vpc_id
}

# --- NEW: Compute Layer (Lambda Functions) ---

module "lambda_primary" {
  source = "../../modules/compute/lambda"
  providers = {
    aws = aws.primary
  }

  environment              = "dev"
  function_name            = "dev-api-handler-primary"
  rds_proxy_endpoint       = module.rds_proxy_primary.proxy_endpoint
  vpc_id                   = module.vpc_primary.vpc_id
  private_subnet_ids       = module.vpc_primary.private_subnet_ids
  lambda_security_group_id = module.security_groups_primary.lambda_sg_id

  depends_on = [module.rds_proxy_primary]
  s3_code_bucket = "lambda-deploys-${var.primary_region}-626690050115"
  s3_code_key    = "dev/api-handler-primary.zip"
}

module "lambda_secondary" {
  source = "../../modules/compute/lambda"
  providers = {
    aws = aws.secondary
  }

  environment              = "dev"
  function_name            = "dev-api-handler-secondary"
  rds_proxy_endpoint       = module.rds_proxy_secondary.proxy_endpoint
  vpc_id                   = module.vpc_secondary.vpc_id
  private_subnet_ids       = module.vpc_secondary.private_subnet_ids
  lambda_security_group_id = module.security_groups_secondary.lambda_sg_id

  depends_on = [module.rds_proxy_secondary]
  s3_code_bucket = "lambda-deploys-${var.secondary_region}-626690050115"
  s3_code_key    = "dev/api-handler-secondary.zip"
}

# --- Authentication Layer ---

# Call the cognito module to create our user directory.
# Since user authentication is centralized, we deploy this module
# ONLY to our primary region by explicitly passing the 'primary' provider.
module "cognito" {
  source = "../../modules/auth/cognito"

  providers = {
    aws = aws.primary
  }

  environment = "dev"
}