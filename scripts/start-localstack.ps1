$ErrorActionPreference = "Stop"

Set-Location (Join-Path $PSScriptRoot "..")

docker compose -f localstack-compose.yml up -d

Write-Host "Waiting for LocalStack..."
$deadline = (Get-Date).AddSeconds(60)

while ((Get-Date) -lt $deadline) {
    try {
        docker compose -f localstack-compose.yml exec -T localstack awslocal s3 ls | Out-Null
        Write-Host "LocalStack is ready."
        exit 0
    }
    catch {
        Start-Sleep -Seconds 2
    }
}

throw "LocalStack did not become ready within 60 seconds."
