variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "region" {
  description = "The AWS region the proxy is deployed in, used to create unique IAM names."
  type        = string
}

variable "db_cluster_identifier" {
  description = "The identifier of the regional Aurora DB cluster."
  type        = string
}

variable "db_credentials_secret_arn" {
  description = "The ARN of the secret containing the DB credentials."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the proxy."
  type        = list(string)
}

variable "proxy_security_group_id" {
  description = "The security group ID to attach to the proxy."
  type        = string
}