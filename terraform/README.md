# Terraform Infrastructure

This directory contains the Terraform configurations for deploying the Plotihub Property Management API on AWS. The infrastructure is structured into environments and reusable modules for consistency, scalability, and maintainability.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Directory Structure](#directory-structure)
- [Environments](#environments)
- [Modules](#modules)
- [Prerequisites](#prerequisites)
- [Deployment](#deployment)
- [Cost Estimates](#cost-estimates)
- [Security](#security)

## 🏗️ Architecture Overview

The Terraform configurations define a complete AWS infrastructure including:

- **Networking**: VPC with public and private subnets
- **Compute**: Elastic Beanstalk with auto-scaling
- **Database**: RDS MySQL with Multi-AZ
- **Storage**: S3 buckets for documents and deployments
- **Authentication**: Amazon Cognito
- **Security**: IAM roles, security groups, secrets management

### Key Design Principles

- **Infrastructure as Code (IaC)**: All resources defined and managed through Terraform
- **Modularity**: Reusable modules for each component
- **Environment Isolation**: Separate configurations per environment
- **Cost Optimization**: Right-sized resources with auto-scaling

## 📂 Directory Structure

```
terraform/
├── environments/
│   └── dev/                    # Development environment
│       ├── main.tf             # Main configuration
│       ├── variables.tf        # Input variables
│       ├── backend.tf          # Terraform backend
│       └── versions.tf         # Version constraints
├── modules/                    # Reusable modules
│   ├── auth/
│   │   └── cognito/           # Cognito User Pools
│   ├── compute/
│   │   └── elastic-beanstalk/ # EB Application & Environment
│   ├── data/
│   │   ├── rds-mysql/         # RDS MySQL Database
│   │   └── secrets/           # Secrets Manager
│   ├── networking/
│   │   ├── security-groups/   # Security Groups
│   │   └── vpc/               # VPC Configuration
│   └── storage/
│       └── s3-documents/       # S3 Buckets
└── README.md                   # This file
```

## 🌍 Environments

### Development (`environments/dev/`)

The development environment configuration deploys:

- Single VPC with public and private subnets
- RDS MySQL database (db.t3.micro)
- Elastic Beanstalk application (t3.micro, 1-4 instances)
- S3 buckets for documents and deployments
- Cognito User Pool for authentication
- Security groups for ALB, EB, and RDS

**Key files:**
- [`main.tf`](environments/dev/main.tf) - Main configuration
- [`variables.tf`](environments/dev/variables.tf) - Environment variables
- [`backend.tf`](environments/dev/backend.tf) - Backend configuration

## 🧩 Modules

### Networking Modules

#### VPC (`modules/networking/vpc/`)
- Creates VPC with CIDR 10.0.0.0/16
- Public and private subnets across availability zones
- Internet Gateway and NAT Gateway
- Route tables for public and private subnets

#### Security Groups (`modules/networking/security-groups/`)
- ALB security group (HTTP/HTTPS)
- EB security group (HTTP from ALB)
- RDS security group (MySQL from EB)

### Compute Modules

#### Elastic Beanstalk (`modules/compute/elastic-beanstalk/`)
- EB Application and Environment
- Python 3.11 platform on Amazon Linux 2023
- Auto-scaling configuration (1-4 instances)
- IAM roles for EC2 and EB service
- Environment variables for database connection

### Data Modules

#### RDS MySQL (`modules/data/rds-mysql/`)
- MySQL 8.0 database
- Multi-AZ deployment for high availability
- Automated backups (7-day retention)
- Encryption at rest

#### Secrets Manager (`modules/data/secrets/`)
- Database credentials storage
- Secure secret rotation

### Storage Modules

#### S3 Documents (`modules/storage/s3-documents/`)
- Documents bucket for uploaded files
- Deploys bucket for EB application packages
- Versioning enabled
- Lifecycle policies for cost optimization

### Auth Modules

#### Cognito (`modules/auth/cognito/`)
- User Pool for authentication
- App Client configuration

## 📋 Prerequisites

Before deploying, ensure you have:

1. **Terraform CLI** (v1.6.0+)
   ```bash
   terraform version
   ```

2. **AWS CLI** configured
   ```bash
   aws configure
   ```

3. **AWS Credentials** with appropriate permissions:
   - EC2, RDS, S3, IAM, Elastic Beanstalk, Cognito
   - Secrets Manager

## 🚀 Deployment

### Deploy Infrastructure

```bash
# Navigate to environment
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Review changes
terraform plan

# Apply changes
terraform apply
```

### Configure Variables

Create a `dev.tfvars` file or use environment variables:

```hcl
environment     = "dev"
primary_region  = "af-south-1"
```

### Destroy Infrastructure

```bash
terraform destroy
```

## 💰 Cost Estimates

### Development Environment (Monthly)

| Service | Configuration | Cost (USD) |
|---------|--------------|-------------|
| EC2 (EBS) | 1 × t3.micro, 8GB SSD | $8.00 |
| RDS MySQL | 1 × db.t3.micro, Multi-AZ | $24.00 |
| S3 | Documents + Deploys (~5GB) | $1.50 |
| NAT Gateway | 1 × nat-1GB-data | $32.00 |
| ALB | Application Load Balancer | $16.00 |
| Data Transfer | ~10GB/month | $1.00 |
| Cognito | 50 MAU | $0.00 |
| Secrets Manager | 1 secret | $0.50 |
| Route 53 | 1 hosted zone | $0.50 |
| EIP | 1 Elastic IP | $3.00 |

**Total: ~$86.50/month**

### Production Environment (Estimated)

| Service | Configuration | Cost (USD) |
|---------|--------------|-------------|
| EC2 (EBS) | 2 × t3.small | $32.00 |
| RDS MySQL | 2 × db.t3.small, Multi-AZ | $120.00 |
| S3 | ~50GB | $5.00 |
| NAT Gateway | 1 × nat-10GB-data | $32.00 |
| ALB | Application Load Balancer | $22.00 |
| Other services | | $15.00 |

**Total: ~$226/month**

## 🔐 Security

### Network Security
- VPC with public/private subnet isolation
- Security groups with least-privilege access
- No public access to RDS or EB instances
- NAT Gateway for outbound internet access

### Data Security
- S3 encryption (AES-256)
- RDS encryption at rest
- Secrets Manager for credentials
- SSL/TLS in transit

### IAM Security
- EB instance profile with limited permissions
- Service roles with minimum required policies
- No root user access

## 🔄 CI/CD Integration

The infrastructure deployment integrates with GitHub Actions:

```yaml
# Trigger on workflow_dispatch or commit message contains [terraform]
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars -auto-approve
```

## 📝 Module Outputs

Key outputs from the deployment:

- `environment_url` - Application URL
- `database_endpoint` - RDS endpoint (sensitive)
- `documents_bucket` - Documents S3 bucket name
- `deploys_bucket` - Deployments S3 bucket name

## 🔧 Customization

### Modify Instance Type

In [`environments/dev/main.tf`](environments/dev/main.tf):
```hcl
module "elastic_beanstalk" {
  instance_type = "t3.small"  # Change from t3.micro
}
```

### Enable Multi-AZ

```hcl
module "rds_mysql" {
  multi_az = true
}
```

### Adjust Auto-Scaling

```hcl
module "elastic_beanstalk" {
  min_instance_count = 2
  max_instance_count = 8
}
```

## 📄 License

This Terraform configuration is part of the Plotihub project licensed under the MIT License.
