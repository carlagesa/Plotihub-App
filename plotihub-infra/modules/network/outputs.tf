output "vpc_id" { value = aws_vpc.this.id }

output "private_app_subnet_ids" {
  value = [for s in aws_subnet.app : s.id]
}

output "private_db_subnet_ids" {
  value = [for s in aws_subnet.db : s.id]
}

output "sg_lambda_id" { value = aws_security_group.lambda.id }
output "sg_rds_proxy_id" { value = aws_security_group.rds_proxy.id }
output "sg_aurora_id" { value = aws_security_group.aurora.id }
output "vpce_sg_id" { value = aws_security_group.vpce.id }

output "vpc_endpoint_ids" {
  value = { for k, v in aws_vpc_endpoint.endpoints : k => v.id }
}
