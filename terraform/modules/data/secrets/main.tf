# This resource generates a strong, random password.
resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# This defines the secret in AWS Secrets Manager.
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.environment}/database-credentials"

  # This block is crucial for multi-region. It automatically creates
  # a read-replica of the secret in our secondary region.
  replica {
    region = var.secondary_region
  }
}

# This resource populates the secret with a value (a "version").
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  # We store the credentials in a structured JSON format, which is easy for applications to parse.
  # The password value comes directly from the 'random_password' resource above.
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.db_password.result
    engine   = "aurora-mysql"
    port     = 3306
  })
}