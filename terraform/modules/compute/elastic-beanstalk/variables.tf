variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "plotihub"
}

variable "instance_type" {
  description = "EC2 instance type for EB"
  type        = string
  default     = "t3.micro"
}

variable "min_instance_count" {
  description = "Minimum number of instances in auto-scaling group"
  type        = number
  default     = 1
}

variable "max_instance_count" {
  description = "Maximum number of instances in auto-scaling group"
  type        = number
  default     = 4
}

variable "vpc_id" {
  description = "VPC ID for the EB environment"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for load balancer"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EC2 instances"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for EB instances"
  type        = string
}

variable "db_host" {
  description = "Database host endpoint"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username (from secrets)"
  type        = string
}

variable "db_password" {
  description = "Database password (from secrets)"
  type        = string
  sensitive   = true
}

variable "rds_security_group_id" {
  description = "Security group ID for RDS"
  type        = string
}
