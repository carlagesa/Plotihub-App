$ErrorActionPreference = "Stop"

$env:AWS_ACCESS_KEY_ID = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"
$env:AWS_DEFAULT_REGION = "af-south-1"
$env:AWS_ENDPOINT_URL = "http://localhost:4566"
$env:AWS_ENDPOINT_URL_S3 = "http://localhost:4566"
$env:AWS_S3_USE_PATH_STYLE = "true"

Set-Location (Join-Path $PSScriptRoot "..\terraform\environments\dev")

terraform init
terraform fmt -check
terraform validate
