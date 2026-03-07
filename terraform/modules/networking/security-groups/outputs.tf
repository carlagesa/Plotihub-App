output "eb_sg_id" {
  description = "The ID of the Elastic Beanstalk security group."
  value       = aws_security_group.eb.id
}

output "rds_sg_id" {
  description = "The ID of the RDS security group."
  value       = aws_security_group.rds.id
}

output "alb_sg_id" {
  description = "The ID of the ALB security group."
  value       = aws_security_group.alb.id
}
