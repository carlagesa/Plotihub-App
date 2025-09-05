output "db_credentials_secret_arn" {
  description = "The ARN of the database credentials secret in Secrets Manager."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_credentials_map" {
  description = "A map containing the raw database username and password."
  value = {
    username = "dbadmin"
    # The value comes directly from the 'random_password' resource in this module
    password = random_password.db_password.result
  }
  # This marks the output as sensitive so the password isn't displayed in logs.
  sensitive = true
}