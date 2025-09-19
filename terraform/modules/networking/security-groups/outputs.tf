output "lambda_sg_id" {
  description = "The ID of the Lambda security group."
  value       = aws_security_group.lambda.id
}

output "rds_proxy_sg_id" {
  description = "The ID of the RDS Proxy security group."
  value       = aws_security_group.rds_proxy.id
}