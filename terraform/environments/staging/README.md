# Staging Environment

Purpose: pre-production validation of the Plotihub infrastructure with staging-sized capacity.

Validate locally with:

```powershell
terraform -chdir=terraform/environments/staging init -backend=false
terraform -chdir=terraform/environments/staging fmt -check
terraform -chdir=terraform/environments/staging validate
```
