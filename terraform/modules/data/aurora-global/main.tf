terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [aws.primary, aws.secondary]
    }
  }
}

# We need to fetch the secret's value to get the username and password for cluster creation.
# This data source reads the latest version of the secret we created earlier.
data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = var.db_credentials_secret_arn
}

# The secret value is a JSON string, so we use the 'jsondecode' function to parse it into a Terraform object.
locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_creds.secret_string)
}

# --- Global Cluster Resource ---
# This is the top-level container for our multi-region database.
resource "aws_rds_global_cluster" "main" {
  global_cluster_identifier = "${var.environment}-aurora-global-db"
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.06.0" # Use a current, valid version
  storage_encrypted         = true
}

# --- Primary Region Resources ---

# A DB subnet group tells RDS which subnets it can place database instances in.
resource "aws_db_subnet_group" "primary" {
  name       = "${var.environment}-primary-db-subnet-group"
  subnet_ids = var.primary_subnet_ids
}

# The primary database cluster. This is the writable master.
resource "aws_rds_cluster" "primary" {
  # This provider alias ensures these resources are created in us-east-1.
  provider = aws.primary

  cluster_identifier      = "${var.environment}-aurora-primary-cluster"
  global_cluster_identifier = aws_rds_global_cluster.main.id
  engine                  = aws_rds_global_cluster.main.engine
  engine_version          = aws_rds_global_cluster.main.engine_version
  db_subnet_group_name    = aws_db_subnet_group.primary.name
  master_username         = local.db_creds.username
  master_password         = local.db_creds.password
  skip_final_snapshot     = true # Set to false for production environments
}

# At least one database instance is required in the primary cluster.
resource "aws_rds_cluster_instance" "primary" {
  provider = aws.primary

  cluster_identifier = aws_rds_cluster.primary.id
  identifier         = "${var.environment}-aurora-primary-instance-1"
  instance_class     = "db.t3.medium" # Choose an appropriate instance size
  engine             = aws_rds_cluster.primary.engine
  engine_version     = aws_rds_cluster.primary.engine_version
}

# --- Secondary Region Resources ---

resource "aws_db_subnet_group" "secondary" {
  name       = "${var.environment}-secondary-db-subnet-group"
  subnet_ids = var.secondary_subnet_ids
}

# The secondary database cluster. This is a read-only replica.
resource "aws_rds_cluster" "secondary" {
  # This provider alias ensures these resources are created in us-east-2.
  provider = aws.secondary

  cluster_identifier      = "${var.environment}-aurora-secondary-cluster"
  global_cluster_identifier = aws_rds_global_cluster.main.id
  engine                  = aws_rds_global_cluster.main.engine
  engine_version          = aws_rds_global_cluster.main.engine_version
  db_subnet_group_name    = aws_db_subnet_group.secondary.name
  skip_final_snapshot     = true

  # This dependency ensures the primary cluster is fully created before the secondary one starts.
  depends_on = [aws_rds_cluster.primary]
}