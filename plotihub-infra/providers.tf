provider "aws" {
  region = var.region_primary
  default_tags {
    tags = {
      Project    = var.project
      Env        = var.env
      ManagedBy  = "Terraform"
      CostCenter = "Plotihub"
    }
  }
}
