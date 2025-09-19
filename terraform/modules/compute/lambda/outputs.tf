output "function_invoke_arn" {
  description = "The ARN to be used for invoking the function from other services."
  value       = aws_lambda_function.api_handler.invoke_arn
}

output "function_name" {
  description = "The name of the Lambda function."
  value       = aws_lambda_function.api_handler.function_name
}