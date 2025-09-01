output "db_credentials_secret_arn" {
  description = "The ARN of the database credentials secret in Secrets Manager."
  value       = aws_secretsmanager_secret.db_credentials.arn
}