provider "aws" {
  region = var.primary_region
}

# --- Provider Configuration ---
provider "aws" {
  region = var.primary_region
  alias  = "primary"
}

provider "aws" {
  region = var.secondary_region
  alias  = "secondary"
}

# --- Networking Layer ---
module "vpc_primary" {
  source = "../../modules/networking/vpc"
  providers = {
    aws = aws.primary
  }
  aws_region  = var.primary_region
  vpc_cidr    = "10.0.0.0/16"
  environment = "dev"
}

module "vpc_secondary" {
  source = "../../modules/networking/vpc"
  providers = {
    aws = aws.secondary
  }
  aws_region  = var.secondary_region
  vpc_cidr    = "10.1.0.0/16"
  environment = "dev"
}

module "security_groups_primary" {
  source = "../../modules/networking/security-groups"
  providers = {
    aws = aws.primary
  }
  environment = "dev"
  vpc_id      = module.vpc_primary.vpc_id
}

module "security_groups_secondary" {
  source = "../../modules/networking/security-groups"
  providers = {
    aws = aws.secondary
  }
  environment = "dev"
  vpc_id      = module.vpc_secondary.vpc_id
}

# --- Data Layer ---
module "secrets" {
  source = "../../modules/data/secrets"
  # No 'providers' block needed - it will automatically use the default provider, which is set to our primary region.
  environment      = "dev"
  secondary_region = var.secondary_region
}

module "aurora_global" {
  source = "../../modules/data/aurora-global"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }
  environment          = "dev"
  primary_vpc_id       = module.vpc_primary.vpc_id
  primary_subnet_ids   = module.vpc_primary.private_subnet_ids
  secondary_subnet_ids = module.vpc_secondary.private_subnet_ids
  db_credentials_map   = module.secrets.db_credentials_map
  depends_on = [
    module.vpc_primary,
    module.vpc_secondary
  ]
}

# --- Compute Layer ---
module "rds_proxy_primary" {
  source = "../../modules/data/rds-proxy"
  providers = {
    aws = aws.primary
  }
  environment               = "dev"
  db_cluster_identifier     = module.aurora_global.primary_cluster_id
  db_credentials_secret_arn = module.secrets.db_credentials_secret_arn
  private_subnet_ids        = module.vpc_primary.private_subnet_ids
  proxy_security_group_id   = module.security_groups_primary.rds_proxy_sg_id
  depends_on = [module.aurora_global]
}

module "rds_proxy_secondary" {
  source = "../../modules/data/rds-proxy"
  providers = {
    aws = aws.secondary
  }
  environment               = "dev"
  db_cluster_identifier     = module.aurora_global.secondary_cluster_id
  db_credentials_secret_arn = module.secrets.db_credentials_secret_arn
  private_subnet_ids        = module.vpc_secondary.private_subnet_ids
  proxy_security_group_id   = module.security_groups_secondary.rds_proxy_sg_id
  depends_on = [module.aurora_global]
}

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
  s3_code_bucket           = "lambda-deploys-${var.primary_region}-626690050115"
  s3_code_key              = "dev/api-handler-primary.zip"
  depends_on               = [module.rds_proxy_primary] # This will now be valid
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
  s3_code_bucket           = "lambda-deploys-${var.secondary_region}-626690050115"
  s3_code_key              = "dev/api-handler-secondary.zip"
  depends_on               = [module.rds_proxy_secondary] # This will now be valid
}

# --- Authentication Layer ---
module "cognito" {
  source = "../../modules/auth/cognito"
  providers = {
    aws = aws.primary
  }
  environment = "dev"
}

# --- API Layer ---

module "api_gateway_primary" {
  source = "../../modules/api/api-gateway"
  providers = {
    aws = aws.primary
  }

  environment                = "dev"
  api_name                   = "dev-serverless-api-primary"
  lambda_function_invoke_arn = module.lambda_primary.function_invoke_arn
  cognito_user_pool_arn      = module.cognito.user_pool_arn
}

module "api_gateway_secondary" {
  source = "../../modules/api/api-gateway"
  providers = {
    aws = aws.secondary
  }

  environment                = "dev"
  api_name                   = "dev-serverless-api-secondary"
  lambda_function_invoke_arn = module.lambda_secondary.function_invoke_arn
  # We point the secondary API Gateway back to the single, centralized Cognito User Pool in the primary region.
  cognito_user_pool_arn      = module.cognito.user_pool_arn
}