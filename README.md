# Plotihub - Property Management API

![Django](https://img.shields.io/badge/Django-4.2-green)
![Python](https://img.shields.io/badge/Python-3.11-blue)
![AWS](https://img.shields.io/badge/AWS-Elastic%20Beanstalk-orange)
![License](https://img.shields.io/badge/License-MIT-yellow)

Plotihub is a property management API built with Django and Django REST Framework, designed specifically for the Kenyan property market. It helps property owners automate rent collection, maintenance logging, and tenant management.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Deployment](#deployment)
- [Project Structure](#project-structure)
- [API Endpoints](#api-endpoints)
- [Contributing](#contributing)
- [License](#license)

## ✨ Features

- **Landlord Management** - Manage multiple property owners
- **Property Management** - Track properties with multiple units
- **Tenant Management** - Handle tenant information and leases
- **Payment Tracking** - Record and track rent payments
- **Maintenance Requests** - Log and manage maintenance issues
- **RESTful API** - Full Django REST Framework support
- **API Documentation** - Interactive Swagger/OpenAPI documentation

## 🏗️ Architecture

```
                          Internet
                             |
                        [Route 53]
                             |
                    [Application Load Balancer]
                             |
                    [Elastic Beanstalk]
                     (Auto-scaling 1-4)
                             |
              +--------------+--------------+
              |              |              |
         [RDS MySQL]    [S3 Storage]  [Cognito]
        (Multi-AZ)      (Documents)   (Auth)
```

### Key Architecture Decisions

- **Compute**: AWS Elastic Beanstalk with Python 3.11
- **Database**: RDS MySQL with Multi-AZ deployment
- **Storage**: S3 for document storage
- **Authentication**: Amazon Cognito for user management
- **CI/CD**: GitHub Actions automated deployments
- **Region**: `af-south-1` (Cape Town) - optimized for Kenya

### Scaling Strategy

- **Normal Operation**: 1 t3.micro instance (~8/month)
- **Peak (End-of-Month)**: Up to 4 instances handle traffic spikes
- **Auto-scaling Trigger**: CPU 30%-80%

### Cost Estimate (Development)

| Service | Monthly Cost |
|---------|-------------|
| EC2 (EB) | $8.00 |
| RDS MySQL (Multi-AZ) | $24.00 |
| S3 Storage | $1.50 |
| NAT Gateway | $32.00 |
| ALB | $16.00 |
| **Total** | **~$81.50/month** |

## 🛠️ Tech Stack

- **Backend**: Django 4.2, Django REST Framework
- **Database**: MySQL 8.0 (RDS)
- **Cloud**: AWS (Elastic Beanstalk, RDS, S3, Cognito)
- **IaC**: Terraform
- **CI/CD**: GitHub Actions
- **Authentication**: JWT via Amazon Cognito

## 🚀 Getting Started

### Prerequisites

- Python 3.11+
- pip
- MySQL client (for local development)
- AWS CLI (for deployment)

### Local Development Setup

1. **Clone the repository:**
```bash
git clone https://github.com/carlagesa/Plotihub-App.git
cd Plotihub-App
```

2. **Create and activate virtual environment:**
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate  # Windows
```

3. **Install dependencies:**
```bash
pip install -r requirements.txt
```

4. **Configure environment variables:**
Create a `.env` file in the project root:
```env
DATABASE_URL=mysql://user:password@localhost:3306/plotihub
SECRET_KEY=your-django-secret-key
DEBUG=True
```

5. **Run database migrations:**
```bash
python manage.py migrate
```

6. **Create superuser (optional):**
```bash
python manage.py createsuperuser
```

7. **Start development server:**
```bash
python manage.py runserver
```

The API will be available at `http://127.0.0.1:8000/`

### Running Tests

```bash
python manage.py test
```

### API Documentation

Once the server is running, access:
- Swagger UI: `http://127.0.0.1:8000/swagger/`
- ReDoc: `http://127.0.0.1:8000/redoc/`

## 📦 Deployment

### Automatic Deployment (GitHub Actions)

The project uses GitHub Actions for automated deployment:

1. **Push to main branch** - Triggers application deployment
2. **Include `[terraform]` in commit** - Triggers infrastructure deployment
3. **Manual trigger** - Use workflow_dispatch for full deployment

### Manual Deployment

**Prerequisites:**
- AWS CLI configured
- EB CLI installed: `pip install awsebcli`

**Steps:**
```bash
# Initialize EB (first time only)
eb init -p python3.11 plotihub --region af-south-1

# Create environment
eb create dev-plotihub --single --region af-south-1

# Deploy updates
eb deploy
```

### Terraform Deployment

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

## 📂 Project Structure

```
Plotihub-App/
├── api/                      # Django app
│   ├── admin.py             # Admin configuration
│   ├── models.py            # Database models
│   ├── serializers.py       # DRF serializers
│   ├── urls.py              # URL routing
│   ├── views.py             # API views
│   └── user/                # User app
├── core/                    # Django project settings
│   ├── settings.py          # Main settings
│   ├── urls.py              # Root URLs
│   └── wsgi.py              # WSGI config
├── terraform/               # Infrastructure as Code
│   ├── environments/        # Environment configs
│   │   └── dev/            # Development environment
│   └── modules/            # Reusable modules
│       ├── auth/cognito/   # Cognito setup
│       ├── compute/eb/     # Elastic Beanstalk
│       ├── data/           # RDS & Secrets
│       ├── networking/     # VPC & Security Groups
│       └── storage/        # S3 buckets
├── .github/workflows/       # CI/CD pipelines
├── manage.py               # Django management script
└── requirements.txt        # Python dependencies
```

## 🔌 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/landlords/` | GET, POST | List/Create landlords |
| `/api/landlords/{id}/` | GET, PUT, DELETE | Manage landlord |
| `/api/properties/` | GET, POST | List/Create properties |
| `/api/properties/{id}/` | GET, PUT, DELETE | Manage property |
| `/api/tenants/` | GET, POST | List/Create tenants |
| `/api/tenants/{id}/` | GET, PUT, DELETE | Manage tenant |
| `/api/leases/` | GET, POST | List/Create leases |
| `/api/payments/` | GET, POST | List/Create payments |
| `/api/maintenance/` | GET, POST | List/Create maintenance requests |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

Built with ❤️ for the Kenyan property market
