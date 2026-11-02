# Production Environment

Purpose: production-capacity Plotihub infrastructure, kept separate from staging state and configuration.

Validate locally with:

```powershell
terraform -chdir=terraform/environments/prod init -backend=false
terraform -chdir=terraform/environments/prod fmt -check
terraform -chdir=terraform/environments/prod validate
```
