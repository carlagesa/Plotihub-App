output "invoke_url" {
  description = "The invocation URL for the API stage."
  value       = aws_api_gateway_stage.main.invoke_url
}

output "rest_api_id" {
  description = "The ID of the REST API."
  value       = aws_api_gateway_rest_api.main.id
}

output "authorizer_id" {
  description = "The ID of the Cognito authorizer."
  value       = aws_api_gateway_authorizer.cognito.id
}