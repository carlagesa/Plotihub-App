output "db_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "db_address" {
  description = "Database address"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.main.port
}

output "db_instance_id" {
  description = "RDS Instance ID"
  value       = aws_db_instance.main.id
}
