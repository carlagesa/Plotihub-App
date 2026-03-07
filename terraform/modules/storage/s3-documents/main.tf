# S3 Module for Document Storage (Receipts, Documents)
# This module provisions S3 buckets for storing application documents
# Variables are defined in variables.tf

# Main Documents Bucket
resource "aws_s3_bucket" "documents" {
  bucket = "${var.bucket_prefix}-documents-${var.environment}"
  
  tags = {
    Name        = "${var.bucket_prefix}-documents-${var.environment}"
    Environment = var.environment
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "documents" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.documents.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "documents" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.documents.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "documents" {
  bucket = aws_s3_bucket.documents.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle rules (transition to Standard-IA after 30 days)
resource "aws_s3_bucket_lifecycle_configuration" "documents" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.documents.id
  
  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value["id"]
      status = rule.value["status"]
      
      dynamic "transition" {
        for_each = contains(keys(rule.value), "transition_days") ? [1] : []
        content {
          days          = rule.value["transition_days"]
          storage_class = rule.value["storage_class"]
        }
      }
      
      dynamic "expiration" {
        for_each = contains(keys(rule.value), "expiration_days") ? [1] : []
        content {
          days = rule.value["expiration_days"]
        }
      }
    }
  }
}

# Lambda function bucket (for EB deployments)
resource "aws_s3_bucket" "deploys" {
  bucket = "${var.bucket_prefix}-deploys-${var.environment}"
  
  tags = {
    Name        = "${var.bucket_prefix}-deploys-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "deploys" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.deploys.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "deploys" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.deploys.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "deploys" {
  bucket = aws_s3_bucket.deploys.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
