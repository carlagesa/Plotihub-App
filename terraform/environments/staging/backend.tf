terraform {
  backend "s3" {
    bucket       = "plotihub-s3-tfstate"
    key          = "staging/terraform.tfstate"
    region       = "af-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
