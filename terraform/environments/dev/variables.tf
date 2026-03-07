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