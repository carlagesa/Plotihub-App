# Plotihub AWS Architecture - Single Region Deployment

## Architecture Overview

This document describes the corrected AWS architecture for the Plotihub Property Management API, optimized for:
- **Primary Region**: `af-south-1` (Cape Town) - Lowest latency to Kenya
- **Solo Developer**: Simple, maintainable infrastructure
- **Cost-Effective**: Avoid over-provisioning while handling traffic spikes

---

## 1. Architecture Components

### Compute: Elastic Beanstalk (Python/Django)

**Why Elastic Beanstalk over Lambda?**
- **Simpler for Django**: No cold start issues, familiar server-based model
- **Built-in auto-scaling**: Handles end-of-month traffic spikes automatically
- **Less complexity**: No need to manage API Gateway, Lambda layers, or VPC configuration
- **Easier debugging**: Standard EC2 instances with SSH access if needed
- **Suitable workload**: Your API has consistent traffic, not purely event-driven

**Configuration**:
- Platform: Python 3.11 on Amazon Linux 2023
- Instance Type: `t3.micro` (development) → `t3.small` (production)
- Auto-scaling: 1-4 instances
- Scaling trigger: CPU 30%-80%

### Database: RDS MySQL (Single-AZ)

**Decision: RDS MySQL over Aurora**
- **Cost**: ~$15/month (t3.micro) vs ~$100/month (Aurora)
- **Simplicity**: Single-AZ is fine for development/small production
- **Growth path**: Can upgrade to Aurora later when needed
- **MySQL 8.0**: Full compatibility with Django

**Configuration**:
- Instance: `db.t3.micro` (free-tier eligible)
- Storage: 20GB gp3 (~$2/month)
- Backups: 7-day retention

### Storage: S3 for Documents

**Buckets**:
1. `plotihub-documents-{env}` - Receipts, uploaded documents
2. `plotihub-deploys-{env}` - Application deployment packages

**Features**:
- Versioning enabled
- Server-side encryption (AES256)
- Lifecycle policies for cost optimization

### Authentication: Amazon Cognito

- User pools for user authentication
- Managed UI for sign-up/sign-in
- JWT tokens for API authorization

### CI/CD: GitHub Actions

**Workflow**:
1. Test job - Runs Django checks
2. Deploy Terraform (manual trigger) - Infrastructure changes
3. Deploy Application - Auto deploys on push to main

---

## 2. Handling End-of-Month Notification Spike

The end-of-month period (28th-31st) sees 10x normal traffic due to rent collection notifications.

### Solution: Elastic Beanstalk Auto-Scaling

```yaml
# EB Auto-Scaling Configuration
Min Instances: 1
Max Instances: 4
Scaling Trigger: CPU Utilization
  - Lower Threshold: 30%
  - Upper Threshold: 80%
  - Period: 5 minutes
  - Evaluation Periods: 2
```

**How It Works**:
1. Normal operation: 1 t3.micro instance (~$8/month)
2. Spike begins: CPU hits 80% → EB launches new instance
3. Peak load: Up to 4 instances handle traffic
4. After spike: Instances scale back down

**Cost Impact**:
- Normal: ~$8/month (1 instance)
- Peak (3 days): ~$12/month (4 instances)
- Average: ~$10/month

### Future Enhancement (When Needed)
For true high availability, upgrade to:
- RDS Multi-AZ ($30/month additional)
- t3.small instances ($16/month each)

---

## 3. Monthly Cost Estimate (af-south-1)

### Development Environment (with Multi-AZ)

| Service | Configuration | Monthly Cost (USD) |
|---------|--------------|-------------------|
| **EC2 (EBS)** | 1 × t3.micro, 8GB SSD | $8.00 |
| **RDS MySQL** | 1 × db.t3.micro, 20GB, Multi-AZ | $24.00 |
| **S3** | Documents + Deploys (~5GB) | $1.50 |
| **NAT Gateway** | 1 × nat-1GB-data | $32.00 |
| **Data Transfer** | ~10GB/month | $1.00 |
| **Cognito** | 50 MAU | $0.00 |
| **Secrets Manager** | 1 secret | $0.50 |
| **Route 53** | 1 hosted zone | $0.50 |
| **CloudWatch** | Basic monitoring | $0.00 |
| **ELB** | Application Load Balancer | $16.00 |
| **EIP** | 1 Elastic IP | $3.00 |
| **VPC** | NAT Gateway hours | Included |
| **EB Platform** | Managed platform | $0.00 |

**Total: ~$86.50/month**

### Production Environment (Larger)

| Service | Configuration | Monthly Cost (USD) |
|---------|--------------|-------------------|
| **EC2 (EBS)** | 2 × t3.small, 30GB SSD | $32.00 |
| **RDS MySQL** | 2 × db.t3.small, Multi-AZ | $120.00 |
| **S3** | Documents (~50GB) | $5.00 |
| **NAT Gateway** | 1 × nat-10GB-data | $32.00 |
| **Data Transfer** | ~50GB/month | $5.00 |
| **Cognito** | 500 MAU | $0.55 |
| **Secrets Manager** | 2 secrets | $1.00 |
| **Route 53** | 1 hosted zone | $0.50 |
| **CloudWatch** | Detailed monitoring | $10.00 |
| **ELB** | Application Load Balancer | $22.00 |
| **EIP** | 1 Elastic IP | $3.00 |

**Total: ~$231/month**

---

## 4. Network Architecture

```
                        Internet
                           |
                           v
                   [Internet Gateway]
                           |
            +--------------+--------------+
            |                             |
      [Public Subnet A]           [Public Subnet B]
            |                             |
      [NAT Gateway]                      |
            |                             |
      +-----+-----+              +-----+-----+
      |           |              |           |
[Private Subnet A]         [Private Subnet B]
      |           |              |           |
  [EB EC2]    [RDS MySQL]    [EB EC2]    [RDS MySQL]
```

**Components**:
- **Public Subnets**: NAT Gateway, Application Load Balancer
- **Private Subnets**: EC2 instances (EB), RDS MySQL
- **Route Tables**: Public (0.0.0.0 → IGW), Private (0.0.0.0 → NAT)

---

## 5. Deployment Steps

### Prerequisites
```bash
# Install AWS CLI and EB CLI
pip install awsebcli

# Configure AWS credentials
aws configure
```

### Infrastructure Deployment (One-time)
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### Application Deployment
```bash
# Initialize EB (first time only)
eb init -p python3.11 plotihub --region af-south-1

# Create environment
eb create dev-plotihub --single --region af-south-1

# Deploy updates
eb deploy
```

### Or Use GitHub Actions
```bash
# Push code to main branch triggers deployment automatically
git push origin main
```

---

## 6. Scaling Strategy

### Scaling Triggers

| Metric | Threshold | Action |
|--------|-----------|--------|
| CPU Utilization | > 80% (5 min) | Add instance |
| CPU Utilization | < 30% (5 min) | Remove instance |
| Request Count | > 1000/min | Add instance |

### Instance Types Growth Path

1. **Development**: t3.micro (1 vCPU, 1GB RAM) - $8/month
2. **Small Production**: t3.small (2 vCPU, 2GB RAM) - $16/month
3. **Medium Production**: t3.medium (2 vCPU, 4GB RAM) - $32/month

---

## 7. Security

### Network Security
- VPC with public/private subnets
- Security groups: ALB → EB → RDS
- No public access to RDS or EB instances

### Data Security
- S3 encryption (AES-256)
- RDS encryption at rest
- Secrets Manager for credentials
- SSL/TLS in transit

### IAM Security
- EB instance profile (limited S3/CloudWatch access)
- No root user access
- Least privilege policies

---

## 8. Migration from Lambda (When Ready)

If you later need Lambda's benefits:

1. Create new Lambda function with Django Zappa/Chalice
2. Add API Gateway integration
3. Test parallel to EB
4. Switch DNS
5. Decommission EB

Current architecture supports easy migration.

---

## 9. Future Enhancements

### Phase 2 (When Revenue Supports)
- [ ] RDS Multi-AZ for HA
- [ ] CloudFront CDN for static assets
- [ ] ElastiCache for Redis (session/caching)
- [ ] Enhanced monitoring

### Phase 3 (Multi-Region)
- [ ] Aurora Global Database
- [ ] Route 53 failover
- [ ] CloudFront Geo routing
