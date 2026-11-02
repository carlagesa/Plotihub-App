#!/bin/sh
set -eu

awslocal s3api create-bucket \
  --bucket plotihub-s3-tfstate \
  --region af-south-1 \
  --create-bucket-configuration LocationConstraint=af-south-1 || true

awslocal s3api create-bucket \
  --bucket plotihub-deploys-dev \
  --region af-south-1 \
  --create-bucket-configuration LocationConstraint=af-south-1 || true

awslocal s3api create-bucket \
  --bucket plotihub-deploys-af-south-1 \
  --region af-south-1 \
  --create-bucket-configuration LocationConstraint=af-south-1 || true

awslocal s3api create-bucket \
  --bucket plotihub-deploys-staging \
  --region af-south-1 \
  --create-bucket-configuration LocationConstraint=af-south-1 || true

awslocal s3api create-bucket \
  --bucket plotihub-deploys-prod \
  --region af-south-1 \
  --create-bucket-configuration LocationConstraint=af-south-1 || true
