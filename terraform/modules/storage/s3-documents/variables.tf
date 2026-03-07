variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "bucket_prefix" {
  description = "Bucket name prefix"
  type        = string
  default     = "plotihub"
}

variable "enable_versioning" {
  description = "Enable versioning for S3 bucket"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for object expiration"
  type        = list(map(any))
  default     = []
}
