# RDS MySQL Module for Single-Region Deployment
# This module provisions a MySQL database with automated backups and Multi-AZ support
# Variables are defined in variables.tf

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier     = "${var.environment}-plotihub-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  # Storage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = 100  # Allows storage to grow up to 100GB
  storage_type          = "gp3"
  storage_encrypted     = true

  # Credentials
  username = var.master_username
  password = var.master_password

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]

  # Backup & Maintenance
  backup_retention_period = var.backup_retention_days
  backup_window           = "03:00-04:00"  # UTC
  maintenance_window      = "mon:04:00-mon:05:00"
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection    = false  # Set to true in production

  # Multi-AZ for high availability
  multi_az = var.multi_az

  # Performance Insights
  monitoring_interval = 0  # Set to 60 for production (adds cost)
  
  # Tags
  tags = {
    Name        = "${var.environment}-plotihub-db"
    Environment = var.environment
  }
}
