output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "A list of the public subnet IDs."
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
  ]
}

output "private_subnet_ids" {
  description = "A list of the private subnet IDs."
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
  ]
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}
