variable "environment" {
  description = "The deployment environment (e.g., dev, prod)."
  type        = string
}

variable "api_name" {
  description = "A name for the REST API."
  type        = string
}

variable "lambda_function_invoke_arn" {
  description = "The ARN of the Lambda function to be invoked by the API."
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "The ARN of the Cognito User Pool to use for authorization."
  type        = string
}