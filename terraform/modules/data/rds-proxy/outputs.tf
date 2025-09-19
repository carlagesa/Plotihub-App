output "proxy_endpoint" {
  description = "The endpoint of the RDS Proxy."
  value       = aws_db_proxy.main.endpoint
}