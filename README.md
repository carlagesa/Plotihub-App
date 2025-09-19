# Multi-Region Serverless Platform for Property Management (🚧In Progress🚧)

[]() <img src="./aws_arch.png" alt="app-screen" width="800" />

## 1. Executive Summary

This repository contains the Infrastructure as Code (IaC) for a production-grade, multi-region serverless platform built on AWS. The platform is designed to power an open-source Property Management API for the Kenyan market, a sector where digital transformation can significantly reduce operational friction for property owners.

The architecture documented here is a blueprint for building modern, cloud-native applications that are **secure, resilient, scalable, and cost-effective by design.**

## 2. The Business Problem & The Cloud Solution

**Problem:** Independent property owners in Kenya face significant administrative overhead, relying on manual processes for rent collection, maintenance logging, and financial reconciliation. This leads to payment delays, poor tenant service, and a lack of data for business decisions.

**Solution:** A centralized, reliable, and low-cost API that automates these core workflows. We chose a multi-region, serverless architecture on AWS to directly address the key business requirements:

*   **Extreme Reliability:** The service must be available 24/7, especially during critical end-of-month payment periods.
*   **Low Operational Cost:** The business model requires a low barrier to entry and operating costs that scale linearly with adoption.
*   **Rapid Feature Development:** The ability to quickly introduce new features (e.g., SMS notifications, online payments) is a key competitive advantage.

## 3. Key Features

*   **High Availability:** Multi-region active-active deployment across two AWS regions with Route 53 DNS Failover and a continuously replicated Aurora MySQL Global Database to withstand regional failures with zero data loss and near-zero downtime.
*   **Scalability:** Automated scaling of compute resources through AWS Lambda and API Gateway, handling massive, spiky traffic patterns without performance degradation. An RDS Proxy manages database connections for graceful scaling.
*   **Resilience:** Self-healing mechanisms inherent in serverless components and Aurora Global Database failover to standby replicas ensure continuous operation.
*   **Cost Optimization:** Implemented strategies to minimize cloud expenditure without compromising performance or reliability, leveraging a serverless, pay-per-request model and Infrastructure as Code for efficient resource management.
*   **Security:** Adherence to security best practices, including network isolation within VPCs, least privilege access via IAM, data encryption at rest and in transit, and secrets management with AWS Secrets Manager. Amazon Cognito provides secure user identity.
*   **Infrastructure as Code (IaC):** All infrastructure defined and managed using Terraform.
*   **CI/CD Pipeline:** Automated deployment of application code and infrastructure changes using GitHub Actions.

## 4. Technologies Used

*   **Cloud Provider:** AWS
*   **Infrastructure as Code:** Terraform
*   **Programming Language (for application):** Python (Django, Django REST Framework)
*   **Database:** Aurora MySQL Global Database
*   **CI/CD:** GitHub Actions
*   **Monitoring & Logging:** AWS CloudWatch, AWS CloudTrail
*   **Version Control:** Git

## 5. Deployment

The entire infrastructure is deployed using Infrastructure as Code.

**Prerequisites:**

*   Terraform CLI installed.
*   AWS CLI configured (e.g., `aws configure`).
*   Necessary IAM permissions.

**Steps:**

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/carlagesa/Plotihub-App.git
    cd Plotihub-App
    ```
2.  **Initialize IaC:**
    ```bash
    # For Terraform:
    cd terraform
    terraform init
    ```
3.  **Review the plan:**
    ```bash
    # For Terraform:
    terraform plan
    ```
4.  **Apply the changes:**
    ```bash
    # For Terraform:
    terraform apply
    ```
    Confirm with `yes` when prompted.

**CI/CD Pipeline (Conceptual):**

A GitHub Actions pipeline is configured to automatically:

*   Trigger on push to `main` branch.
*   Run `terraform plan` and wait for manual approval (for infrastructure changes).
*   Execute `terraform apply`.
*   Deploy new application versions to AWS Lambda/API Gateway.

## 6. Cost Analysis & Optimization

Cost management was a critical aspect of this project. The following strategies were employed to ensure efficient use of resources and minimize operational expenditure:

*   **Right-Sizing:** Continuously monitored resource utilization of database instances to select appropriate instance types.
*   **Auto Scaling:** Dynamically adjusted compute capacity based on actual demand through serverless AWS Lambda, ensuring resources are scaled down during off-peak hours and scaled up only when needed, preventing over-provisioning.
*   **Serverless Adoption:** Leveraged serverless functions (AWS Lambda) for event-driven tasks and APIs, paying only for compute duration and invocations, eliminating idle costs.
*   **Storage Tiering:** Utilized different storage classes for S3 (e.g., S3 Standard-IA, Glacier) based on data access patterns and retention policies for cost-effective data archival (conceptual, as S3 is not explicitly in current architecture but good practice).
*   **Managed Services:** Opted for managed services (Aurora MySQL, API Gateway, RDS Proxy, Lambda) to offload operational overhead and reduce costs associated with OS patching, backups, and high availability setup.
*   **Reserved Instances/Savings Plans (Future/Consideration):** While not implemented in a personal project, for production environments, analyzing historical usage to purchase Reserved Instances or Savings Plans would provide significant discounts for predictable workloads.
*   **Tagging and Cost Allocation:** Implemented a tagging strategy (e.g., Project, Environment, Owner) to track resource usage and allocate costs effectively, enabling better visibility and accountability.
*   **Deletion of Unused Resources:** Automated cleanup of stale or unused resources (e.g., old snapshots, untagged volumes) to prevent accrual of unnecessary costs (conceptual, as specific automation not detailed).

**Example Cost Breakdown (Hypothetical for a small deployment):**

| Service             | Monthly Cost (Approx.) | Optimization Strategy Applied                               |
| :------------------ | :--------------------- | :---------------------------------------------------------- |
| AWS Lambda/API Gateway | $10                    | Serverless Adoption, Auto Scaling                           |
| Aurora MySQL Global DB | $100                   | Right-Sizing, Managed Service, Multi-Region for HA (not solely cost) |
| RDS Proxy           | $15                    | Managed Service                                             |
| Route 53            | $2                     | Necessary for HA                                            |
| AWS Secrets Manager | $1                     | Managed Service                                             |
| Amazon Cognito      | $5                     | Managed Service                                             |
| Data Transfer       | $5                     | Monitored, minimized cross-AZ where possible                |
| **Total Est. Monthly** | **$138**               |                                                             |

*Note: These are illustrative figures. Actual costs would depend on usage, region, and specific configurations.*

## 7. Security Considerations

Security was paramount throughout the design and implementation.

*   **Network Isolation:**
    *   Resources deployed in a Virtual Private Cloud (VPC) with private subnets for application servers (Lambda VPC access) and databases.
    *   Public subnets only host public-facing components like API Gateway endpoints (implicitly managed by AWS).
    *   NAT Gateways enable private instances/Lambda functions to access the internet securely without public IPs.
*   **Least Privilege Access (IAM/RBAC):**
    *   Strict IAM policies applied to Lambda execution roles and other services, granting only the necessary permissions to perform their functions.
    *   Avoided root user for daily operations.
    *   Used instance profiles/managed identities for services to access other cloud resources.
*   **Security Groups/Network Security Groups (NSGs):**
    *   Configured with minimal inbound rules, allowing traffic only on required ports from trusted sources (e.g., Lambda to RDS Proxy on database port).
*   **Data Encryption:**
    *   **At Rest:** All data stored in Aurora MySQL Global Database is encrypted using AWS-managed keys (KMS).
    *   **In Transit:** All communication between components (e.g., API Gateway to Lambda, Lambda to RDS Proxy, RDS Proxy to database) is encrypted using SSL/TLS.
*   **Secrets Management:**
    *   Sensitive credentials (e.g., database passwords, API keys) are stored and retrieved using AWS Secrets Manager rather than hardcoding.
*   **Web Application Firewall (WAF) (Optional/Future):**
    *   Could be integrated with API Gateway to protect against common web exploits (e.g., SQL injection, XSS) by filtering malicious traffic before it reaches the application.
*   **Vulnerability Scanning:**
    *   Regularly scanned Lambda function code and dependencies for known vulnerabilities (conceptual, as specific tools not detailed).
*   **Auditing:**
    *   AWS CloudTrail is enabled to record API calls and resource changes, providing an audit trail for security analysis.

## 8. Monitoring & Logging

Comprehensive monitoring and logging are essential for operational visibility, troubleshooting, and proactive issue detection.

*   **Centralized Logging:**
    *   Application logs from AWS Lambda are streamed to AWS CloudWatch Logs.
    *   Infrastructure logs (AWS CloudTrail, VPC Flow Logs) are also collected and analyzed.
    *   Log retention policies configured for compliance and historical analysis.
*   **Performance Metrics:**
    *   AWS CloudWatch collects metrics for Lambda invocations, errors, duration, API Gateway latency, database connections, CPU utilization, etc.
    *   Custom metrics can be pushed for application-specific insights.
*   **Alerting:**
    *   Alarms configured based on critical metrics (e.g., high Lambda error rates, high database CPU utilization, API Gateway 5xx errors).
    *   Notifications sent via [SNS/PagerDuty/Slack/Email] to relevant teams.
*   **Dashboards:**
    *   Custom dashboards created in AWS CloudWatch to visualize key performance indicators (KPIs) and system health at a glance.

## 9. Future Enhancements

*   **CI/CD Pipeline Expansion:** Implement blue/green deployments or canary releases for zero-downtime application updates.
*   **CDN Integration:** Use Amazon CloudFront for static assets (if a frontend is added) to improve global performance and reduce load on application servers.
*   **Serverless Refactoring:** Identify additional components suitable for serverless functions to further reduce operational overhead and cost.
*   **Chaos Engineering:** Introduce controlled failures to test system resilience and identify weak points.
*   **Cost Optimization Automation:** Implement automated scripts or policies to identify and clean up unused resources.
*   **Disaster Recovery:** Further enhance disaster recovery strategies, potentially exploring multi-region active-active for all components if not already fully implemented.

## 10. Local Development & Testing

Instructions for setting up the project locally for development and testing.

**Prerequisites:**

*   Python 3.x
*   `pip` (Python package installer)
*   `virtualenv` (recommended)
*   MySQL client libraries (if connecting directly to a local MySQL instance for development)

**Steps:**

1.  **Create and activate a virtual environment:**
    ```bash
    python -m venv venv
    source venv/bin/activate
    ```
2.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```
3.  **Configure environment variables:**
    Create a `.env` file in the `core/` directory for local database connection details and any necessary API keys.
    Example `.env` content:
    ```
    DATABASE_URL=mysql://user:password@host:port/database_name
    SECRET_KEY=your_django_secret_key
    ```
4.  **Run database migrations:**
    ```bash
    python manage.py migrate
    ```
5.  **Create a superuser (optional):**
    ```bash
    python manage.py createsuperuser
    ```
6.  **Run tests:**
    ```bash
    python manage.py test
    ```
7.  **Start application:**
    ```bash
    python manage.py runserver
    ```
    The API will be available at `http://127.0.0.1:8000/`.

## 11. Contributing

This is a personal project, but suggestions and feedback are welcome.

## 12. License

This project is licensed under the MIT License.