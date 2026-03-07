# Security Groups for Single-Region Deployment with Elastic Beanstalk

# Security Group for Elastic Beanstalk (EC2 instances)
resource "aws_security_group" "eb" {
  name_prefix = "${var.environment}-eb-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for Elastic Beanstalk EC2 instances"

  # Allow outbound HTTPS for application to call external APIs
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow HTTP for local development
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for RDS MySQL
resource "aws_security_group" "rds" {
  name_prefix = "${var.environment}-rds-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for RDS MySQL database"
  
  # No inbound rules - access controlled by source security groups
}

# Security Group for Application Load Balancer
resource "aws_security_group" "alb" {
  name_prefix = "${var.environment}-alb-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for Application Load Balancer"

  # Allow HTTP and HTTPS from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Security Group Rules ---

# Rule: Allow EB instances to connect to RDS on MySQL port (3306)
resource "aws_security_group_rule" "eb_to_rds" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
  security_group_id        = aws_security_group.eb.id
  description              = "Allow EB to connect to RDS MySQL"
}

# Rule: Allow ALB to connect to EB instances on HTTP (port 80)
resource "aws_security_group_rule" "alb_to_eb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.eb.id
  description              = "Allow ALB to connect to EB instances"
}

# Rule: Allow RDS to receive connections from EB on MySQL port
resource "aws_security_group_rule" "rds_from_eb" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eb.id
  security_group_id        = aws_security_group.rds.id
  description              = "Allow RDS to receive connections from EB"
}
