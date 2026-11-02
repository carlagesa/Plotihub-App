variable "primary_region" {
  type        = string
  description = "AWS region used for the staging environment."
  default     = "af-south-1"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "staging"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "min_instance_count" {
  type    = number
  default = 1
}

variable "max_instance_count" {
  type    = number
  default = 3
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "tags" {
  type = map(string)
  default = {
    Project = "Plotihub"
  }
}
