# --- Provider Configuration ---
# provider "aws" {
#   region = var.primary_region
#   alias  = "primary"
# }

# For Local stack only
provider "aws" {
  alias                       = "primary"    # ← add this
  region                      = "af-south-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3       = "http://s3.localhost.localstack.cloud:4566"
    sts      = "http://localhost:4566"
    iam      = "http://localhost:4566"
    lambda   = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    rds      = "http://localhost:4566"      # ← also add missing services
    ec2      = "http://localhost:4566"
    elasticbeanstalk = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
  }
}

# --- Networking Layer ---
module "vpc" {
  source = "../../modules/networking/vpc"
  providers = {
    aws = aws.primary
  }
  aws_region  = var.primary_region
  vpc_cidr    = "10.0.0.0/16"
  environment = var.environment
}

module "security_groups" {
  source = "../../modules/networking/security-groups"
  providers = {
    aws = aws.primary
  }
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

# --- Data Layer ---
module "secrets" {
  source = "../../modules/data/secrets"
  environment = var.environment
  # No secondary region needed for single-region
}

module "rds_mysql" {
  source = "../../modules/data/rds-mysql"
  providers = {
    aws = aws.primary
  }
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnet_ids
  security_group_id      = module.security_groups.rds_sg_id
  db_instance_class      = "db.t3.micro"  # Smallest for dev - upgrade for prod
  allocated_storage      = 20
  db_name                 = "plotihub"
  master_username        = "plotihub_admin"
  master_password        = module.secrets.db_credentials_map.password
  backup_retention_days  = 7
  skip_final_snapshot    = true
  multi_az              = true  # Enable Multi-AZ for high availability
}

# --- Storage Layer ---
module "s3_storage" {
  source = "../../modules/storage/s3-documents"
  providers = {
    aws = aws.primary
  }
  environment  = var.environment
  bucket_prefix = "plotihub"
  
  # Lifecycle rules for cost optimization
  lifecycle_rules = [
    {
      id      = "archive-old-documents"
      status  = "Enabled"
      transition_days = 30
      storage_class   = "STANDARD_IA"
    },
    {
      id      = "delete-old-versions"
      status  = "Enabled"
      expiration_days = 365
    }
  ]
}

# --- Compute Layer ---
module "elastic_beanstalk" {
  source = "../../modules/compute/elastic-beanstalk"
  providers = {
    aws = aws.primary
  }
  environment            = var.environment
  app_name              = "plotihub"
  instance_type         = "t3.micro"  # t3.micro is free-tier eligible
  min_instance_count    = 1
  max_instance_count    = 4  # Scales up for end-of-month spikes
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  security_group_id     = module.security_groups.eb_sg_id
  db_host               = split(":", module.rds_mysql.db_endpoint)[0]
  db_name               = "plotihub"
  db_username           = "plotihub_admin"
  db_password           = module.secrets.db_credentials_map.password
  rds_security_group_id = module.security_groups.rds_sg_id
  
  depends_on = [module.rds_mysql]
}

# --- Authentication Layer ---
module "cognito" {
  source = "../../modules/auth/cognito"
  providers = {
    aws = aws.primary
  }
  environment = var.environment
}

# --- Outputs ---
output "environment_url" {
  description = "Application URL"
  value       = "https://${module.elastic_beanstalk.eb_cname}"
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = module.rds_mysql.db_endpoint
  sensitive   = true
}

output "documents_bucket" {
  description = "Documents S3 bucket"
  value       = module.s3_storage.documents_bucket_name
}

output "deploys_bucket" {
  description = "Deploys S3 bucket"
  value       = module.s3_storage.deploys_bucket_name
}
