# Security Group for the Lambda Function
resource "aws_security_group" "lambda" {
  name_prefix = "${var.environment}-lambda-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for the API Lambda function"

  # By default, Lambdas in a VPC have no internet access.
  # This allows outbound HTTPS traffic (e.g., to call other AWS APIs).
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for the RDS Proxy
resource "aws_security_group" "rds_proxy" {
  name_prefix = "${var.environment}-rds-proxy-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for the RDS Proxy"
}

# --- Security Group Rules ---
# These separate rule resources allow us to connect the two groups without creating a circular dependency.

# Rule: Allow Lambda to connect to the RDS Proxy on the MySQL port (3306)
resource "aws_security_group_rule" "lambda_to_proxy" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_proxy.id # The destination
  security_group_id        = aws_security_group.lambda.id    # The source
  description              = "Allow Lambda to connect to RDS Proxy"
}

# Rule: Allow the RDS Proxy to receive connections from Lambda on the MySQL port
resource "aws_security_group_rule" "proxy_from_lambda" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lambda.id # The source
  security_group_id        = aws_security_group.rds_proxy.id # The destination
  description              = "Allow RDS Proxy to receive connections from Lambda"
}