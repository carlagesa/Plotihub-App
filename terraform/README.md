# Terraform Infrastructure

This directory contains the Terraform configurations for deploying the Multi-Region Serverless Platform for Property Management on AWS. It is structured into environments and reusable modules to promote consistency, scalability, and maintainability.

## 1. Architecture Overview

The Terraform configurations define the entire cloud infrastructure, including networking, compute, data services, and security components. Key architectural principles applied here include:

*   **Infrastructure as Code (IaC):** All resources are defined and managed through Terraform, enabling version control, automation, and reproducibility.
*   **Modularity:** The infrastructure is broken down into reusable modules, each encapsulating a specific set of resources (e.g., VPC, API Gateway, Aurora).
*   **Environment-Specific Deployments:** Separate configurations for different environments (e.g., `dev`) ensure isolation and tailored deployments.
*   **Multi-Region Design:** Configurations support deploying an active-active architecture across multiple AWS regions for high availability and disaster recovery.

## 2. Environments

Each environment directory contains the specific configuration for deploying the platform to a particular stage (e.g., development, staging, production).

*   **`environments/dev/`**:
    *   This directory holds the Terraform configuration for the development environment.
    *   It orchestrates the deployment of various modules to create a fully functional development instance of the platform.
    *   Key files:
        *   [`main.tf`](terraform/environments/dev/main.tf): Main configuration file, orchestrating module calls.
        *   [`variables.tf`](terraform/environments/dev/variables.tf): Defines input variables specific to the `dev` environment.
        *   [`backend.tf`](terraform/environments/dev/backend.tf): Configures the Terraform backend (e.g., S3 for state management).
        *   [`versions.tf`](terraform/environments/dev/versions.tf): Specifies required Terraform and provider versions.

## 3. Modules

The `modules/` directory contains reusable Terraform modules. Each module is a self-contained package of Terraform configurations that manages a specific component or set of components.

*   **`modules/api/api-gateway/`**:
    *   Manages the AWS API Gateway resources, including REST APIs, methods, integrations (e.g., with Lambda), and deployment stages.
    *   Provides the public-facing endpoint for the application's API.
*   **`modules/auth/cognito/`**:
    *   Configures AWS Cognito User Pools and Identity Pools for user authentication and authorization.
    *   Handles user registration, login, and token management.
*   **`modules/compute/lambda/`**:
    *   Defines AWS Lambda functions, their execution roles (IAM), and associated permissions.
    *   Used for deploying the serverless API handlers and other event-driven compute tasks.
*   **`modules/data/aurora-global/`**:
    *   Sets up an AWS Aurora MySQL Global Database, including primary and secondary clusters in different regions.
    *   Ensures high availability, disaster recovery, and read replica capabilities.
*   **`modules/data/rds-proxy/`**:
    *   Deploys an AWS RDS Proxy to manage and pool database connections for Aurora.
    *   Improves application scalability and resilience by handling connection spikes and database failovers transparently.
*   **`modules/data/secrets/`**:
    *   Manages AWS Secrets Manager secrets for storing sensitive information like database credentials and API keys.
    *   Ensures secure storage and retrieval of application secrets.
*   **`modules/networking/security-groups/`**:
    *   Defines AWS Security Groups to control inbound and outbound traffic for various resources.
    *   Enforces network isolation and least privilege access.
*   **`modules/networking/vpc/`**:
    *   Configures the AWS Virtual Private Cloud (VPC), including subnets (public, private), route tables, internet gateways, and NAT gateways.
    *   Provides the foundational network infrastructure for all deployed resources.

## 4. Lambda Functions

The `lambda-functions/` directory contains the source code for AWS Lambda functions deployed by the Terraform configurations.

*   **`lambda-functions/api-handler/`**:
    *   Contains the Python code for the primary API handler Lambda function.
    *   This function processes requests routed from API Gateway and interacts with the backend services.
    *   Key file: [`lambda_function.py`](terraform/lambda-functions/api-handler/lambda_function.py)

## 5. Deployment

To deploy the infrastructure for a specific environment:

**Prerequisites:**

*   Terraform CLI installed (ensure version compatibility as specified in `versions.tf`).
*   AWS CLI configured with appropriate credentials and default region.
*   Necessary IAM permissions to create and manage AWS resources.

**Steps:**

1.  **Navigate to the desired environment directory:**
    ```bash
    cd terraform/environments/dev # or your target environment
    ```
2.  **Initialize Terraform:**
    This command downloads necessary providers and modules, and sets up the backend for state management.
    ```bash
    terraform init
    ```
3.  **Review the execution plan:**
    This command shows what actions Terraform will take without actually making any changes. Review it carefully.
    ```bash
    terraform plan
    ```
4.  **Apply the changes:**
    This command applies the planned changes to your AWS account. You will be prompted to confirm.
    ```bash
    terraform apply
    ```
    Type `yes` and press Enter when prompted to confirm the deployment.

## 6. CI/CD Integration

The deployment of this Terraform infrastructure is integrated with a CI/CD pipeline (e.g., GitHub Actions). The pipeline typically automates the `terraform plan` and `terraform apply` steps, often including manual approval gates for critical infrastructure changes.

## 7. Contributing

For contributions or modifications to the Terraform configurations:

*   Follow the existing module structure and naming conventions.
*   Ensure all new resources are properly tagged.
*   Test changes thoroughly in a development environment before proposing them for higher environments.

## 8. License

This Terraform infrastructure is part of the larger project licensed under the MIT License.