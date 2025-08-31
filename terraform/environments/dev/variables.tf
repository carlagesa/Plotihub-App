variable "primary_region" {
  description = "The primary AWS region."
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "The secondary AWS region."
  type        = string
  default     = "us-east-2"
}