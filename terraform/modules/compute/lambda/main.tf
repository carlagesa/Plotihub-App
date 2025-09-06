# The CI/CD pipeline will be responsible for creating the zip file.
# The AWS Lambda Function resource itself.
resource "aws_lambda_function" "api_handler" {
  function_name = var.function_name
  
  # These arguments tell the Lambda function to source its code from an S3 bucket.
  # The bucket will be created by our GitHub Actions workflow initially
  s3_bucket = var.s3_code_bucket
  s3_key    = var.s3_code_key

  # This flag is CRITICAL. It tells Terraform to check for new versions of the
  # S3 object (our zip file) on every 'apply'. If a pipeline has uploaded a
  # new version, 'terraform apply' will update the function to point to it.
  # While day-to-day deployments are done via CI/CD, this keeps the state consistent.
  publish = true
  

  role    = aws_iam_role.lambda_execution.arn
  handler = "index.handler"
  runtime = "nodejs18.x"
  timeout = 30

  environment {
    variables = {
      RDS_PROXY_ENDPOINT = var.rds_proxy_endpoint
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }
}