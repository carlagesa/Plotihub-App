# This resource defines the REST API container itself.
resource "aws_api_gateway_rest_api" "main" {
  name        = var.api_name
  description = "REST API for the ${var.environment} environment"
}

# This defines the authorizer that protects our API. It's linked to our Cognito User Pool.
# Any request to a protected endpoint must include a valid ID Token from a logged-in user.
resource "aws_api_gateway_authorizer" "cognito" {
  name          = "${var.environment}-cognito-authorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.main.id
  provider_arns = [var.cognito_user_pool_arn]
}

# This creates a resource (a path segment) in our API. Here, a top-level '/items' path.
resource "aws_api_gateway_resource" "items" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "items" # e.g., https://<api-id>.execute-api.us-east-1.amazonaws.com/v1/items
}

# This defines a specific HTTP verb (POST) on the '/items' resource.
resource "aws_api_gateway_method" "post_item" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.items.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

# This is the "backend" connection. It defines how the POST method above should
# be integrated with our Lambda function.
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.items.id
  http_method             = aws_api_gateway_method.post_item.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY" # This type passes the entire request to Lambda
  uri                     = var.lambda_function_invoke_arn
}

# This permission allows API Gateway to invoke our Lambda function.
# Without this, API Gateway would get a 'permission denied' error.
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_invoke_arn
  principal     = "apigateway.amazonaws.com"

  # The source_arn locks this permission down so only this specific API Gateway
  # can invoke the function. The format is for any method on any path.
  source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# An API Gateway deployment is a snapshot of the API's resources and methods.
# You must create a deployment to make the API callable.
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  # This lifecycle block is important. It tells Terraform to create a new deployment
  # whenever a change is made to any of the API's components.
  lifecycle {
    create_before_destroy = true
  }

  # This 'depends_on' is a way to trigger a redeployment when the integration changes.
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.items.id,
      aws_api_gateway_method.post_item.id,
      aws_api_gateway_integration.lambda.id
    ]))
  }
}

# A stage is a named reference to a deployment, like 'dev', 'v1', or 'prod'.
# It is the final step to make your API publicly accessible.
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "v1"
}