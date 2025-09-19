variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "function_name" {
  description = "The name for the Lambda function."
  type        = string
}

variable "rds_proxy_endpoint" {
  description = "The endpoint of the RDS Proxy in this region."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy the Lambda into."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the Lambda."
  type        = list(string)
}

variable "lambda_security_group_id" {
  description = "The ID of the security group to attach to the Lambda."
  type        = string
}

variable "s3_code_bucket" {
  description = "The name of the S3 bucket where the Lambda deployment package is stored."
  type        = string
}

variable "s3_code_key" {
  description = "The key (path/filename) of the deployment package in the S3 bucket."
  type        = string
}