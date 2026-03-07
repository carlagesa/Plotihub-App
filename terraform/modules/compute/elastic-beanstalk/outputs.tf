output "eb_environment_url" {
  description = "Elastic Beanstalk environment URL"
  value       = aws_elastic_beanstalk_environment.env.endpoint_url
}

output "eb_environment_name" {
  description = "Elastic Beanstalk environment name"
  value       = aws_elastic_beanstalk_environment.env.name
}

output "eb_cname" {
  description = "Elastic Beanstalk CNAME"
  value       = aws_elastic_beanstalk_environment.env.cname
}

output "instance_profile_name" {
  description = "EC2 Instance Profile name"
  value       = aws_iam_instance_profile.eb_ec2.name
}
