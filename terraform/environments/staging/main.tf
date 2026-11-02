provider "aws" {
  alias                       = "primary"
  region                      = var.primary_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3               = "http://s3.localhost.localstack.cloud:4566"
    sts              = "http://localhost:4566"
    iam              = "http://localhost:4566"
    rds              = "http://localhost:4566"
    ec2              = "http://localhost:4566"
    elasticbeanstalk = "http://localhost:4566"
    secretsmanager   = "http://localhost:4566"
    cognitoidp       = "http://localhost:4566"
    cloudwatch       = "http://localhost:4566"
    cloudwatchlogs   = "http://localhost:4566"
  }
}

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

module "secrets" {
  source      = "../../modules/data/secrets"
  environment = var.environment
}

module "rds_mysql" {
  source = "../../modules/data/rds-mysql"
  providers = {
    aws = aws.primary
  }
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnet_ids
  security_group_id     = module.security_groups.rds_sg_id
  db_instance_class     = var.db_instance_class
  allocated_storage     = 20
  db_name               = "plotihub"
  master_username       = "plotihub_admin"
  master_password       = module.secrets.db_credentials_map.password
  backup_retention_days = var.backup_retention_days
  skip_final_snapshot   = true
  multi_az              = var.multi_az
}

module "s3_storage" {
  source = "../../modules/storage/s3-documents"
  providers = {
    aws = aws.primary
  }
  environment   = var.environment
  bucket_prefix = "plotihub"
  lifecycle_rules = [
    {
      id              = "archive-old-documents"
      status          = "Enabled"
      transition_days = 30
      storage_class   = "STANDARD_IA"
    },
    {
      id              = "delete-old-versions"
      status          = "Enabled"
      expiration_days = 365
    }
  ]
}

module "elastic_beanstalk" {
  source = "../../modules/compute/elastic-beanstalk"
  providers = {
    aws = aws.primary
  }
  environment           = var.environment
  app_name              = "plotihub"
  instance_type         = var.instance_type
  min_instance_count    = var.min_instance_count
  max_instance_count    = var.max_instance_count
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  security_group_id     = module.security_groups.eb_sg_id
  db_host               = split(":", module.rds_mysql.db_endpoint)[0]
  db_name               = "plotihub"
  db_username           = "plotihub_admin"
  db_password           = module.secrets.db_credentials_map.password
  rds_security_group_id = module.security_groups.rds_sg_id
  deployment_bucket     = module.s3_storage.deploys_bucket_name
  deployment_key        = "django-app.zip"

  depends_on = [module.rds_mysql]
}

module "cognito" {
  source = "../../modules/auth/cognito"
  providers = {
    aws = aws.primary
  }
  environment = var.environment
}

output "environment_url" {
  value = "https://${module.elastic_beanstalk.eb_cname}"
}

output "database_endpoint" {
  value     = module.rds_mysql.db_endpoint
  sensitive = true
}
