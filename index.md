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
        [Super Linter](https://github.com/LT-Linas35/nextcloud_server/blob/dev/.github/workflows/super-linter.yml)  
        [SonarCloud Scanner](https://github.com/LT-Linas35/nextcloud_server/blob/dev/.github/workflows/Sonar-Cloud-Scanner.yml)
  - **On Release**:
    - Super Linter and Sonar Cloud Scanner workflows. 
    - Calls API to `final_project` to build Docker image: [Release Workflow](https://github.com/LT-Linas35/nextcloud_server/blob/dev/.github/workflows/Super-Linter-and-Sonar-Cloud-Scanner-Release.yaml)).

### Infrastructure as Code (IaC) - LaC
- **Repository**: [final_project](https://github.com/LT-Linas35/final_project)
  - **GitHub Actions**:
    - On Push to `main`: ([SonarCloud](https://github.com/LT-Linas35/final_project/blob/main/.github/workflows/sonar-cloud.yml)) and  ([Trivy](https://github.com/LT-Linas35/final_project/blob/main/.github/workflows/trivy.yml)).
    - On Dispatch: ([Terraform Apply](https://github.com/LT-Linas35/final_project/blob/main/.github/workflows/terraform-apply.yml)).
    - API call from `nextcloud_server` for CI pipeline ([main.yml](https://github.com/LT-Linas35/final_project/blob/main/.github/workflows/main.yml)).

- **Helm Chart**: [NextCloud Helm Chart](helm-charts/nextcloud-chart) for Kubernetes deployment.
- **Server**: [NextCloud Dockerfile](server/Dockerfile).
- **Terraform**: Complete AWS infrastructure setup ([terraform](terraform/)).

---

## Terraform Configuration and Modules

### Configuration File
- **Variables**: [terraform.tfvars](terraform/terraform.tfvars)  
  Central file with configurations for all modules. For security group configurations, see [securitygroups module](terraform/modules/securitygroups/).

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
  - **Bastion**:  
    Connects to the Controller (only created if set to 1, default 0).
    - **Ingress**: 22 TCP from all sources
    - **Egress**: Controller CIDR
  - **Controller**:  
    kOps control plane, stores sensitive data ([controller.sh](terraform/scripts/controller.sh))  
    Safe to shut down after cluster creation.
    - **Ingress**: 22 TCP from Bastion CIDR
    - **Egress**: All sources
- **RDS Module**:  
  Database for NextCloud data.
  - **Ingress**: 3306 TCP from Kubernetes subnet
  - **Egress**: Kubernetes subnet
- **Redis Module**:  
  Cache for NextCloud.
  - **Ingress**: 6379 TCP from Kubernetes subnet
  - **Egress**: Kubernetes subnet
- **S3 Module**:
  - **State Buckets**:
    - kOps state storage.
    - kOps OIDC configuration files.

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
  - **NewRelic**: Add credentials in [main.yml](.github/workflows/main.yml) for PHP monitoring:
    - `NEW_RELIC_API_KEY_PHP`, `NEW_RELIC_ACCOUNT_ID_PHP`, `NR_INSTALL_KEY_PHP`.

### Terraform Cloud Setup
- Configure variables in Terraform Cloud ([Terraform Cloud](https://app.terraform.io/session)).
- Set NextCloud Helm Chart values in [values.yaml](https://github.com/LT-Linas35/final_project/blob/main/helm-charts/nextcloud-chart/values.yaml).

---

## Deployment Steps

1. **Build Release**: [Create release](https://github.com/LT-Linas35/nextcloud_server/releases).
2. **Build Infrastructure**: Trigger [Terraform Apply](https://github.com/LT-Linas35/final_project/actions/workflows/terraform-apply.yml).  
   _Deployment may take up to 30 minutes._
3. **View LoadBalancers**: ArgoCD and NextCloud load balancers available in AWS Console.
