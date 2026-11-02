# Terraform Environments

Purpose: isolate development, staging, and production infrastructure configuration and state.

Use one example variables file per environment:

```powershell
terraform -chdir=terraform/environments/staging init
terraform -chdir=terraform/environments/staging fmt
terraform -chdir=terraform/environments/staging validate
```
