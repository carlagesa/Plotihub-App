variable "environment" {
  description = "The deployment environment (e.g., dev, prod)."
  type        = string
}

variable "secondary_region" {
  description = "The secondary AWS region to replicate the secret to."
  type        = string
}