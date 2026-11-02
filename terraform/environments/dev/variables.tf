variable "primary_region" {
  description = "The primary AWS region - af-south-1 for lowest latency to Kenya"
  type        = string
  default     = "af-south-1"
}

variable "environment" {
  description = "Development environment"
  type        = string
  default     = "dev"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class for this environment."
  default     = "db.t3.micro"
}

variable "instance_type" {
  type        = string
  description = "Elastic Beanstalk EC2 instance type."
  default     = "t3.micro"
}

variable "min_instance_count" {
  type        = number
  description = "Minimum number of Elastic Beanstalk instances."
  default     = 1
}

variable "max_instance_count" {
  type        = number
  description = "Maximum number of Elastic Beanstalk instances."
  default     = 4
}

variable "multi_az" {
  type        = bool
  description = "Whether RDS uses Multi-AZ deployment."
  default     = true
}

variable "backup_retention_days" {
  type        = number
  description = "Number of automated RDS backups retained."
  default     = 7
}

variable "tags" {
  type        = map(string)
  description = "Additional resource tags."
  default = {
    Project = "Plotihub"
  }
}