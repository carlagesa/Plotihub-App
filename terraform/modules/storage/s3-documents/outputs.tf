output "documents_bucket_name" {
  description = "Documents S3 bucket name"
  value       = aws_s3_bucket.documents.id
}

output "documents_bucket_arn" {
  description = "Documents S3 bucket ARN"
  value       = aws_s3_bucket.documents.arn
}

output "deploys_bucket_name" {
  description = "Deploys S3 bucket name"
  value       = aws_s3_bucket.deploys.id
}

output "deploys_bucket_arn" {
  description = "Deploys S3 bucket ARN"
  value       = aws_s3_bucket.deploys.arn
}
