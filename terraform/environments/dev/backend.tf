terraform {
  backend "s3" {
    bucket       = "plotihub-s3-tfstate"
    key          = "dev/terraform.tfstate"
    region       = "af-south-1"
    encrypt      = true
    use_lockfile = true # This enables native S3 state locking
    endpoints = {
      s3 = "http://localhost:4566"
    }
    use_path_style = true
  }
}