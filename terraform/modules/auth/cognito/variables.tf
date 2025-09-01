# This file defines the input variables that our Cognito module accepts.
variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
}