# This defines the IAM Role that our Lambda function will assume when it runs.
resource "aws_iam_role" "lambda_execution" {
  name = "${var.environment}-lambda-execution-role"

  # This is the trust policy, allowing the Lambda service to assume this role.
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# This is the standard AWS-managed policy that grants permissions to write logs
# to CloudWatch and create network interfaces within our VPC.
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# A custom policy to grant additional permissions.
resource "aws_iam_policy" "lambda_policy" {
  name = "${var.environment}-lambda-custom-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Allow the function to put traces into AWS X-Ray for observability.
        Effect = "Allow",
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ],
        Resource = "*" # For X-Ray, this is standard.
      }
      // We could add permissions to access Secrets Manager here if needed later.
    ]
  })
}

resource "aws_iam_role_policy_attachment" "custom_policy_attach" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}