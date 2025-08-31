output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "A list of the private subnet IDs."
  # We combine the IDs from our two private subnets into a single list output.
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
  ]
}