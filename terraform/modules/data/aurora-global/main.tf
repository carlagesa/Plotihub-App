# This module provisions a complete, multi-region AWS Aurora Global Database.
# It is designed to be called from a root module and requires provider aliases
# ('aws.primary' and 'aws.secondary') to be passed to it.

# --- Global Cluster Resource ---

# This resource defines the top-level container for our multi-region database.
# It doesn't contain any data itself but manages the replication and failover
# characteristics between the regional clusters.
resource "aws_rds_global_cluster" "main" {
  # A unique identifier for the global cluster across all of AWS.
  global_cluster_identifier = "${var.environment}-aurora-global-db"

  # Specifies the database engine and version. All regional clusters
  # within this global cluster must use the same engine and version.
  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.06.0"

  # Ensures the database storage is encrypted at rest, a security best practice.
  storage_encrypted = true
}

# --- Primary Region Resources ---
# These resources will be created in the region associated with the 'aws.primary' provider alias.

# A DB Subnet Group tells RDS which subnets within a VPC it can place database instances into.
# This is required for creating a cluster in a VPC.
resource "aws_db_subnet_group" "primary" {
  name       = "${var.environment}-primary-db-subnet-group"
  subnet_ids = var.primary_subnet_ids
}

# This is the primary database cluster. It is the main writable master.
resource "aws_rds_cluster" "primary" {
  # This meta-argument explicitly tells Terraform to use the 'primary' provider
  # alias, ensuring this cluster is created in the correct region (e.g., us-east-1).
  provider = aws.primary

  # Links this regional cluster to the global cluster defined above.
  global_cluster_identifier = aws_rds_global_cluster.main.id
  cluster_identifier        = "${var.environment}-aurora-primary-cluster"
  engine                    = aws_rds_global_cluster.main.engine
  engine_version            = aws_rds_global_cluster.main.engine_version
  db_subnet_group_name      = aws_db_subnet_group.primary.name

  # --- IMPORTANT ---
  # The master credentials are now passed directly into this module via the
  # 'db_credentials_map' variable. This creates a clear dependency graph and avoids
  # the race condition that occurred when using a 'data' source to look up the secret.
  master_username = var.db_credentials_map["username"]
  master_password = var.db_credentials_map["password"]

  # For production, this should be set to 'false' to ensure a final backup is taken on deletion.
  skip_final_snapshot = true
}

# A cluster needs at least one database instance (a virtual server) to run on.
resource "aws_rds_cluster_instance" "primary" {
  provider = aws.primary

  cluster_identifier = aws_rds_cluster.primary.id
  identifier         = "${var.environment}-aurora-primary-instance-1"
  instance_class     = "db.r6g.large" # Choose an instance size appropriate for your workload.
  engine             = aws_rds_cluster.primary.engine
  engine_version     = aws_rds_cluster.primary.engine_version
}

# --- Secondary Region Resources ---
# These resources will be created in the region associated with the 'aws.secondary' provider alias.

# A data source to look up the default AWS-managed KMS key for RDS in the secondary region.
# KMS keys are regional, so we must explicitly find the key in the target region
# to encrypt our cross-region replica.
data "aws_kms_alias" "rds_secondary" {
  provider = aws.secondary
  name     = "alias/aws/rds"
}

# A separate DB Subnet Group for the secondary region, using subnets from the secondary VPC.
resource "aws_db_subnet_group" "secondary" {
  provider = aws.secondary

  name       = "${var.environment}-secondary-db-subnet-group"
  subnet_ids = var.secondary_subnet_ids
}

# This is the secondary database cluster. It is a read-only replica of the primary.
resource "aws_rds_cluster" "secondary" {
  # Explicitly use the 'secondary' provider to create this in our failover region.
  provider = aws.secondary

  # Links this cluster to the same global cluster, making it a replica.
  global_cluster_identifier = aws_rds_global_cluster.main.id
  cluster_identifier        = "${var.environment}-aurora-secondary-cluster"
  engine                    = aws_rds_global_cluster.main.engine
  engine_version            = aws_rds_global_cluster.main.engine_version
  db_subnet_group_name      = aws_db_subnet_group.secondary.name
  skip_final_snapshot       = true

  # Provides the ARN of the KMS key from the secondary region to encrypt this replica's storage.
  # This is mandatory for encrypted global databases.
  kms_key_id = data.aws_kms_alias.rds_secondary.target_key_arn

  # This explicit dependency tells Terraform to wait until the primary cluster is
  # fully created before attempting to create the secondary replica.
  depends_on = [aws_rds_cluster.primary]
}