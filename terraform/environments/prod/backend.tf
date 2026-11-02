terraform {
  backend "s3" {
    bucket       = "plotihub-s3-tfstate"
    key          = "prod/terraform.tfstate"
    region       = "af-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
