terraform {
  backend "s3" {
    bucket         = "plotihub-s3-tfstate"
    key            = "dev/plotihub-serverless-api/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true # This enables native S3 state locking
  }
}