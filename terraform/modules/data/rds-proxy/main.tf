# This IAM Role allows the RDS Proxy service to assume it.
resource "aws_iam_role" "proxy_role" {
  name = "${var.environment}-${var.region}-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "rds.amazonaws.com"
      }
    }]
  })
}

# This policy allows the role to fetch the database password from Secrets Manager.
resource "aws_iam_policy" "proxy_policy" {
  name = "${var.environment}-${var.region}-rds-proxy-policy"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action   = ["secretsmanager:GetSecretValue"],
      Effect   = "Allow",
      Resource = var.db_credentials_secret_arn
    }]
  })
}

# Attach the policy to the role.
resource "aws_iam_role_policy_attachment" "proxy_attach" {
  role       = aws_iam_role.proxy_role.name
  policy_arn = aws_iam_policy.proxy_policy.arn
}

# This is the RDS Proxy resource itself.
resource "aws_db_proxy" "main" {
  name                   = "${var.environment}-rds-proxy"
  debug_logging          = false
  engine_family          = "MYSQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.proxy_role.arn
  vpc_security_group_ids = [var.proxy_security_group_id]
  vpc_subnet_ids         = var.private_subnet_ids

  # Configure authentication. We tell the proxy to use the secret.
  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED" # We use IAM for the proxy-to-secret connection, not app-to-proxy
    secret_arn  = var.db_credentials_secret_arn
  }
}

# This resource configures the SETTINGS for the proxy's default target group.
# It does NOT define what the target is.
resource "aws_db_proxy_default_target_group" "default" {
  db_proxy_name = aws_db_proxy.main.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 100
    max_idle_connections_percent = 50
  }
}

# This resource REGISTER'S a database as a target for the proxy's target group.
# This is what creates the actual connection link.
resource "aws_db_proxy_target" "cluster" {
  db_proxy_name         = aws_db_proxy.main.name
  target_group_name     = aws_db_proxy_default_target_group.default.name
  db_cluster_identifier = var.db_cluster_identifier
}