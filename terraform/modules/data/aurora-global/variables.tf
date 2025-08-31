variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "primary_vpc_id" {
  description = "The VPC ID for the primary region."
  type        = string
}

variable "primary_subnet_ids" {
  description = "List of private subnet IDs for the primary database cluster."
  type        = list(string)
}

variable "secondary_subnet_ids" {
  description = "List of private subnet IDs for the secondary database cluster."
  type        = list(string)
}

variable "db_credentials_secret_arn" {
  description = "The ARN of the secret containing the master DB credentials."
  type        = string
}