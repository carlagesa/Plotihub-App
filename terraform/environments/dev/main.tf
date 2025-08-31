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