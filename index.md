# NextCloud for Company X

This NextCloud deployment serves as a comprehensive file storage and collaboration platform for Company X, supporting secure file storage, document management, real-time chat, and office file editing capabilities. This facilitates seamless teamwork and productivity across the organization.

---

## Tools Overview

### Application
- **NextCloud**: Centralized platform for file storage, document management, and collaboration.

### CI/CD Infrastructure
- **CI**:
  - **GitHub**: Source code and CI workflows.
    - **GitHub Actions**: Automated testing and scanning workflows for code quality.
  - **Docker Image**: Containerized NextCloud application.
  - **Docker Registry**: Repository for storing NextCloud Docker images.
- **CD**:
  - **ArgoCD**: Manages continuous delivery to Kubernetes.
    - **Argo Rollouts**: Canary deployments for progressive delivery.
    - **ArgoCD Image Updater**: Automated image updates.
    - **kubectl Argo Rollouts Plugin**: Manages rollout operations for ArgoCD.
- **Cluster Management**:
  - **kOps**: Cluster management tool for Kubernetes on AWS.
  - **Kubernetes**: Container orchestration.
    - **Controllers**:
      - **Ingress-Nginx**: HTTP load balancer and proxy.
    - **Helm**: Package manager for Kubernetes.
    - **k9s**: CLI for managing Kubernetes clusters.
- **Infrastructure**:
  - **AWS**: Cloud provider.
    - **aws-cli**: CLI for interacting with AWS services.
    - **RDS**: Managed relational database service used to store NextCloud’s database.
    - **Redis**: In-memory data store used for caching to improve NextCloud performance.
    - **EC2**: Compute instances for hosting applications and managing the Kubernetes cluster.
    - **VPC**: Virtual Private Cloud providing a secure network for all infrastructure.
    - **S3**: Object storage used for storing NextCloud files and kOps state files.
- **Monitoring and Logging**:
  - **NewRelic**: Monitoring and observability platform.

---

## CI/CD Pipeline

### Continuous Integration (CI)
- **Repository**: [nextcloud_server](https://github.com/LT-Linas35/nextcloud_server)  
  - **On Push**:
    - SuperLinter and SonarCloud for code linting and scanning, results available in the Security tab.
  - **On Release**:
    - SuperLinter and SonarCloud scanners execute, then trigger Docker image build in `final_project`.

- **Repository**: [final_project](https://github.com/LT-Linas35/final_project)
  - **Docker Image Build**: Builds and pushes NextCloud Docker image to registry `linas37/nextcloud`.
  - **Security Scanning**: Scans images with Trivy; results accessible in the Security tab.
  - **SonarCloud Analysis**: Automated scan on each registry push.

### Continuous Delivery (CD)
- **ArgoCD**:
  - Watches Docker registry `linas37/nextcloud` for `latest` tag.
  - Checks for updates every few minutes and deploys with rolling deployment upon detecting a new image.

---

## Project Overview

### NextCloud Source Code
- **Repository**: [nextcloud_server (branch: dev)](https://github.com/LT-Linas35/nextcloud_server)
  - **GitHub Actions**:
    - On Push to `dev`: 
      - [Super Linter](https://github.com/LT-Linas35/nextcloud_server/blob/dev/.github/workflows/super-linter.yml)  
      - [SonarCloud Scanner](https://github.com/LT-Linas35/nextcloud_server/blob/dev/.github/workflows/Sonar-Cloud-Scanner.yml)
  - **On Release**:
    - Super Linter and Sonar Cloud Scanner workflows. 
    - Calls API to `final_project` to build [Docker image](https://github.com/LT-Linas35/nextcloud_server/blob/dev/.github/workflows/Super-Linter-and-Sonar-Cloud-Scanner-Release.yaml).

### Infrastructure as Code (IaC) - LaC
- **Repository**: [final_project](https://github.com/LT-Linas35/final_project)
  - **GitHub Actions**:
    - On Push to `main`: ([SonarCloud](https://github.com/LT-Linas35/final_project/blob/main/.github/workflows/sonar-cloud.yml)) and  ([Trivy](https://github.com/LT-Linas35/final_project/blob/main/.github/workflows/trivy.yml)).
    - On Dispatch: ([Terraform Apply](https://github.com/LT-Linas35/final_project/blob/main/.github/workflows/terraform-apply.yml)).
    - API call from `nextcloud_server` for CI pipeline ([main.yml](https://github.com/LT-Linas35/final_project/blob/main/.github/workflows/main.yml)).

- **Helm Chart**: [NextCloud Helm Chart](https://github.com/LT-Linas35/final_project/tree/main/helm-charts/nextcloud-chart) for Kubernetes deployment.
- **Server**: [NextCloud Dockerfile](https://github.com/LT-Linas35/final_project/blob/main/server/Dockerfile).
- **Terraform**: Complete AWS infrastructure setup ([terraform](https://github.com/LT-Linas35/final_project/tree/main/terraform)).

---

## Terraform Configuration and Modules

### Configuration File
- **Variables**: [terraform.tfvars](https://github.com/LT-Linas35/final_project/blob/main/terraform/terraform.tfvars)  
  Central file with configurations for all modules. For security group configurations, see [securitygroups module](https://github.com/LT-Linas35/final_project/tree/main/terraform/modules/securitygroups).

### Modules Overview
- **VPC Module**:
  - CIDR: `10.0.0.0/16`  
    Contains subnets for various components:
    - `10.0.1.0/24`: Kubernetes nodes
    - `10.0.2.0/24`: Network Load Balancer
    - `10.0.3.0/24`: Controller EC2 instance
    - `10.0.4.0/24`: Bastion EC2 instance
    - `10.0.5.0/24`: Redis
    - `10.0.6.0/24` and `10.0.7.0/24`: RDS Instances
- **EC2 Module**:
  - **Bastion**: Connects to the Controller (only created if set to 1, default 0).
    - **Ingress**: 22 TCP from all sources
    - **Egress**: Controller CIDR
  - **Controller**: kOps control plane, stores sensitive data ([controller.sh](https://github.com/LT-Linas35/final_project/blob/main/terraform/scripts/controller.sh)) Safe to shut down after cluster creation.
    - **Ingress**: 22 TCP from Bastion CIDR
    - **Egress**: All sources
- **RDS Module**: Database for NextCloud data.
  - **Ingress**: 3306 TCP from Kubernetes subnet
  - **Egress**: Kubernetes subnet
- **Redis Module**: Cache for NextCloud.
  - **Ingress**: 6379 TCP from Kubernetes subnet
  - **Egress**: Kubernetes subnet
- **S3 Module**:
  - **State Buckets**:
    - kOps state storage.
    - kOps OIDC configuration files.
- **Users**:
  - **Username**: `kops`
    - **Group**: `kops`
    - **Attached Policies**:
      - `AmazonEC2FullAccess`
      - `AmazonRoute53FullAccess`
      - `AmazonS3FullAccess`
      - `IAMFullAccess`
      - `AmazonVPCFullAccess`
      - `AmazonSQSFullAccess`
      - `AmazonEventBridgeFullAccess`
    - **Purpose**: This user is utilized for kOps administration, providing access to manage EC2, Route 53, S3, IAM, VPC, SQS, and EventBridge resources.
  - **Username**: `nextcloud-s3-user`
  - **Policy**: `s3-user-policy`
    -  **Permissions**:
      - `s3:CreateBucket`
      - `s3:ListBucket`
      - `s3:GetObject`
      - `s3:PutObject`
      - `s3:DeleteObject`
    - **Resources**:
      - `arn:aws:s3:::${var.nextcloud_install.S3_BUCKET}`
      - `arn:aws:s3:::${var.nextcloud_install.S3_BUCKET}/*`
    - **Purpose**: This user is designated for storing NextCloud data in AWS S3, with the necessary permissions to manage the specified S3 bucket and its contents.
    
---

## Logging and Monitoring

### NewRelic
- **AWS Infrastructure Metrics**: Monitors resource usage and performance.
- **Kubernetes & NextCloud Metrics**: Tracks pod metrics and application logs.
- **NextCloud PHP Monitoring**: Observes performance for PHP-based operations in NextCloud.

---

## Pre-Deployment Setup

### NextCloud Setup
- [nextcloud_server](https://github.com/LT-Linas35/nextcloud_server) branch `dev`.
  - Set up SonarCloud: Requires `SONAR_TOKEN` from SonarCloud (configured in GitHub Secrets).
  - Set up token for API calls in [release workflow](https://github.com/LT-Linas35/nextcloud_server/blob/dev/Super-Linter-and-Sonar-Cloud-Scanner-Release.yaml).

### Final Project Setup
- [final_project](https://github.com/LT-Linas35/final_project)
  - GitHub Actions configuration:
    - **SonarCloud**: Requires `SONAR_TOKEN`.
    - **Terraform Apply**: Requires `TF_CLOUD_ORGANIZATION`, `TF_API_TOKEN`, and `TF_WORKSPACE`.
    - **Docker Registry**: Requires `DOCKER_USERNAME` and `DOCKER_PASSWORD`.
  - **NewRelic**: Add credentials in security for PHP monitoring :
    - `NEW_RELIC_API_KEY_PHP`, `NEW_RELIC_ACCOUNT_ID_PHP`, `NR_INSTALL_KEY_PHP`.
    - [main.yml](.github/workflows/main.yml)

### Terraform Cloud Setup

# Terraform Cloud and Helm Setup for NextCloud

This guide provides a complete setup process for configuring **Terraform Cloud**, managing infrastructure variables, and deploying **NextCloud** using **Helm**.

### 1. Configure Variables in Terraform Cloud

To deploy your infrastructure, navigate to [Terraform Cloud](https://app.terraform.io/session) and set up the following variables:

- **AWS Credentials**:
  - **`AWS_ACCESS_KEY_ID`**: Your AWS access key, required to interact with AWS resources.
  - **`AWS_SECRET_ACCESS_KEY`**: AWS secret key, ensuring secure authentication.

- **NewRelic Configuration**:
  - **`newrelic`** (as a JSON object):
    ```json
    {
      "newrelic_global_licenseKey": "YOUR_LICENSE_KEY"
    }
    ```
  - **`newrelic_global_licenseKey`**: License key for monitoring with NewRelic.

- **NextCloud Installation Configuration**:
  - **`nextcloud_install`** (as a JSON object):
    ```json
    {
      "ADMIN_USER": "YOUR_USERNAME",
      "ADMIN_PASSWORD": "YOUR_PASSWORD",
      "ADMIN_EMAIL": "YOUR_EMAIL"
    }
    ```
  - **`ADMIN_USER`**, **`ADMIN_PASSWORD`**, **`ADMIN_EMAIL`**: Administrative credentials for NextCloud.

- **RDS Database Credentials**:
  - **`rds`** (as a JSON object):
    ```json
    {
      "username": "NEXTCLOUD_DB_USERNAME",
      "password": "NEXTCLOUD_DB_PASSWORD"
    }
    ```
  - **`username`** and **`password`**: RDS instance credentials for NextCloud.

- **Cluster Configuration**:
  - **`cluster`** (as a JSON object):
    ```json
    {
      "ARGOCD_PASSWORD": "YOUR_PASSWORD"
    }
    ```
  - **`ARGOCD_PASSWORD`**: Password required to access ArgoCD.

### 2. Terraform Variables Configuration [`terraform.tfvars`](https://github.com/LT-Linas35/final_project/blob/main/terraform/terraform.tfvars)



### 3. Configure Helm Chart Values for NextCloud Deployment ([`values.yaml`](https://github.com/LT-Linas35/final_project/blob/main/helm-charts/nextcloud-chart/values.yaml)

The following `values.yaml` configuration is used to deploy NextCloud via Helm. Properly configuring these values ensures a smooth deployment:


### Summary
This guide details all the necessary steps to configure your variables in **Terraform Cloud**, set up the required `terraform.tfvars`, and configure **NextCloud** deployment using Helm via `values.yaml`. This will ensure a smooth deployment process for both your infrastructure and application.



---

## Deployment Steps

1. **Build Release**: [Create release](https://github.com/LT-Linas35/nextcloud_server/releases).
2. **Build Infrastructure**: Trigger [Terraform Apply](https://github.com/LT-Linas35/final_project/actions/workflows/terraform-apply.yml).  
   _Deployment may take up to 30 minutes._

---

## After Deployment

### 1. View Load Balancers
- You can find the ArgoCD and NextCloud load balancers in the **AWS Console** under the Load Balancers section.

### 2. Log in to Controller
To securely connect to the Controller instance via the Bastion server, follow these steps:

1. **Set Up Bastion Server**:
   - Open the [`terraform.tfvars`](https://github.com/LT-Linas35/final_project/blob/main/terraform/terraform.tfvars) file.
   - Set `bastion = 1` to enable the Bastion server. This will create a Bastion EC2 instance.
   - Run `terraform apply` to apply the changes.

2. **Configure SSH Access**:
   - On your local machine, create or update the SSH configuration file at `~/.ssh/config` with the following:

     ```plaintext
     Host bastion-server
         HostName <BASTION_IP>
         User ec2-user
         IdentityFile <KEY_BASTION.pem>

     Host 10.0.3.*
         User ec2-user
         IdentityFile <KEY_CONTROLLER.pem>
         ProxyJump bastion-server
     ```

   - Replace `<BASTION_IP>`, `<KEY_BASTION.pem>`, and `<KEY_CONTROLLER.pem>` with the actual Bastion IP and the paths to your PEM key files.

3. **Connect to the Controller**:
   - Use the following SSH command to connect to the Controller instance through the Bastion server:

     ```bash
     ssh <controller_ip>
     ```

   - Replace `<controller_ip>` with the actual IP of the Controller instance.

4. **Disable Bastion After Debugging**:
   - Once debugging is complete, return to [`terraform.tfvars`](https://github.com/LT-Linas35/final_project/blob/main/terraform/terraform.tfvars).
   - Set `bastion = 0` to disable the Bastion server. This will destroy the Bastion EC2 instance.
   - Run `terraform apply` again to apply the changes.

