# Plotihub LocalStack

Purpose: run the Plotihub AWS Terraform stack on the local machine without an AWS account.

## Prerequisites

- Docker Desktop with the Docker Compose plugin
- Terraform 1.6 or newer
- AWS CLI v2

## Start

From the repository root:

```powershell
docker compose -f localstack-compose.yml up -d
aws --endpoint-url=http://localhost:4566 s3 ls
```

The ready hook creates the Terraform state bucket and the EB deployment buckets:

- `plotihub-s3-tfstate`
- `plotihub-deploys-dev`
- `plotihub-deploys-af-south-1`

## Initialize and validate Terraform

```powershell
$env:AWS_ACCESS_KEY_ID="test"
$env:AWS_SECRET_ACCESS_KEY="test"
$env:AWS_DEFAULT_REGION="af-south-1"
$env:AWS_ENDPOINT_URL="http://localhost:4566"
$env:AWS_ENDPOINT_URL_S3="http://localhost:4566"
$env:AWS_S3_USE_PATH_STYLE="true"

cd terraform\environments\dev
terraform init
terraform validate
terraform plan
```

Do not run `terraform apply` unless this LocalStack workflow has been extended and explicitly approved for local-only use.

## Stop

```powershell
docker compose -f localstack-compose.yml down
```
