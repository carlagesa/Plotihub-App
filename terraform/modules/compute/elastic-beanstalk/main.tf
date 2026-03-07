# Elastic Beanstalk Module for Django Application
# This module provisions a complete EB environment with Python platform
# Variables are defined in variables.tf

# Get current region for S3 bucket naming
data "aws_region" "current" {}

# EB Application
resource "aws_elastic_beanstalk_application" "app" {
  name        = var.app_name
  description = "Plotihub Property Management API"
}

# EB Application Version - will be updated by CI/CD pipeline
resource "aws_elastic_beanstalk_application_version" "default" {
  name        = "initial-version-${timestamp()}"
  application = aws_elastic_beanstalk_application.app.name
  bucket      = "plotihub-deploys-${data.aws_region.current.name}"
  key         = "dev/django-app.zip"
}

# Option Settings for Python/Django
locals {
  option_settings = [
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "InstanceType"
      value     = var.instance_type
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "EC2KeyName"
      value     = "" # Leave empty - can be configured later for SSH access
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "IamInstanceProfile"
      value     = aws_iam_instance_profile.eb_ec2.name
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "SecurityGroups"
      value     = var.security_group_id
    },
    {
      namespace = "aws:autoscaling:asg"
      name      = "MinSize"
      value     = var.min_instance_count
    },
    {
      namespace = "aws:autoscaling:asg"
      name      = "MaxSize"
      value     = var.max_instance_count
    },
    {
      namespace = "aws:autoscaling:trigger"
      name      = "MeasureName"
      value     = "CPUUtilization"
    },
    {
      namespace = "aws:autoscaling:trigger"
      name      = "Statistic"
      value     = "Average"
    },
    {
      namespace = "aws:autoscaling:trigger"
      name      = "Period"
      value     = "5"
    },
    {
      namespace = "aws:autoscaling:trigger"
      name      = "EvaluationPeriods"
      value     = "2"
    },
    {
      namespace = "aws:autoscaling:trigger"
      name      = "LowerThreshold"
      value     = "30"
    },
    {
      namespace = "aws:autoscaling:trigger"
      name      = "UpperThreshold"
      value     = "80"
    },
    {
      namespace = "aws:elasticbeanstalk:environment"
      name      = "EnvironmentType"
      value     = "LoadBalanced"
    },
    {
      namespace = "aws:elasticbeanstalk:environment"
      name      = "ServiceRole"
      value     = aws_iam_role.eb.name
    },
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "DJANGO_SETTINGS_MODULE"
      value     = "core.settings"
    },
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "DB_HOST"
      value     = var.db_host
    },
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "DB_NAME"
      value     = var.db_name
    },
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "DB_USER"
      value     = var.db_username
    },
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "DB_PASSWORD"
      value     = var.db_password
    },
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "PYTHON_VERSION"
      value     = "3.11"
    },
    {
      namespace = "aws:elasticbeanstalk:container:python"
      name      = "StaticFiles"
      value     = "/static/:static/"
    },
    {
      namespace = "aws:elb:loadbalancer"
      name      = "CrossZone"
      value     = "true"
    }
  ]
}

# EB Environment
resource "aws_elastic_beanstalk_environment" "env" {
  name                = "${var.app_name}-${var.environment}"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "Python 3.11 running on 64bit Amazon Linux 2023"
  # Use version from CI/CD
  version_label      = aws_elastic_beanstalk_application_version.default.name

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.private_subnet_ids)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", var.public_subnet_ids)
  }

  # Apply all option settings
  dynamic "setting" {
    for_each = local.option_settings
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
    }
  }
}

# IAM Service Role for Elastic Beanstalk
resource "aws_iam_role" "eb" {
  name = "elastic-beanstalk-service-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eb_enhanced_health" {
  role       = aws_iam_role.eb.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "eb_service" {
  role       = aws_iam_role.eb.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

# IAM Instance Profile for EC2 instances in EB
resource "aws_iam_instance_profile" "eb_ec2" {
  name = "eb-ec2-instance-profile-${var.environment}"
  role = aws_iam_role.ec2_eb_role.name
}

resource "aws_iam_role" "ec2_eb_role" {
  name = "ec2-eb-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eb_ec2_cw" {
  role       = aws_iam_role.ec2_eb_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "eb_ec2_s3" {
  role       = aws_iam_role.ec2_eb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}