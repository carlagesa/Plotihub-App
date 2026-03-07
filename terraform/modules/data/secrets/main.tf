# Secrets Module for Single-Region Deployment
# This module creates database credentials stored in AWS Secrets Manager

# This resource generates a strong, random password.
resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# This defines the secret in AWS Secrets Manager.
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.environment}/database-credentials"
  description = "Database credentials for Plotihub ${var.environment} environment"
  
  # Single-region - no replica needed
}

# This resource populates the secret with a value (a "version").
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  # Store credentials in structured JSON format for MySQL
  secret_string = jsonencode({
    username = "plotihub_admin"
    password = random_password.db_password.result
    engine   = "mysql"
    host     = "localhost"  # Will be overridden by application
    port     = 3306
    dbname   = "plotihub"
  })
}
