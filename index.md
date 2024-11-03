# NextCloud for Company X

This NextCloud deployment serves as a comprehensive file storage and collaboration platform for Company X, supporting secure file storage, document management, real-time chat, and office file editing capabilities. This facilitates seamless teamwork and productivity across the organization.

---

## Project Overview

### NextCloud Source Code
- **Repository**: [nextcloud_server (branch: dev)](https://github.com/LT-Linas35/nextcloud_server)  
  _Stores the main application code for NextCloud._
- **GitHub Actions**:
  - **On Push to `dev`**:
    - [Super Linter]([https://github.com/LT-Linas35/nextcloud_server/blob/dev/.github/workflows/super-linter.yml])  
      _Automated code quality checks for the project._
    - [Sonar Cloud Scanner]([https://github.com/LT-Linas35/nextcloud_server/blob/dev/.github/workflows/Sonar-Cloud-Scanner.yml]) (_requires `secrets.SONAR_TOKEN`_)  
      _Performs code analysis to identify issues and maintain code quality._
  - **On Release**:
    - [Super Linter and Sonar Cloud Scanner Release Workflow]([https://github.com/LT-Linas35/nextcloud_server/blob/dev/Super-Linter-and-Sonar-Cloud-Scanner-Release.yaml])  
      _Runs automated code checks and Sonar analysis on release._
    - **Trigger Build**: Sends API call to `final_project` to build NextCloud Docker image (_requires `secrets.workflow_token` and final_project token_)  
      _Automates Docker image build and deploy process on release._

---

### Infrastructure as Code (IaC) – [final_project](https://github.com/LT-Linas35/final_project)

- **GitHub Actions**:
  - **On Push to `main`**:
    - [Sonar Cloud Scanner](.github/workflows/sonar-cloud.yml) (_requires `secrets.SONAR_TOKEN`_)  
      _Runs Sonar analysis for code quality._
    - [Trivy Scanner](.github/workflows/trivy.yml)  
      _Scans Docker images for security vulnerabilities._
  - **Manual Dispatch**:
    - [Terraform Apply](.github/workflows/terraform-apply.yml) (_requires configuration for `TF_CLOUD_ORGANIZATION`, `TF_WORKSPACE`, and `secrets.TF_API_TOKEN`_)  
      _Runs Terraform to manage and apply infrastructure changes._
  - **API Call from `nextcloud_server`**: CI pipeline with Trivy and Docker image publish ([main.yml](.github/workflows/main.yml))  
    _Automates the CI/CD process for publishing Docker images._

- **Helm Charts**: [NextCloud Helm Chart](helm-charts/nextcloud-chart)  
  _Deploys NextCloud on Kubernetes using Helm._
- **Server**: [NextCloud Dockerfile](server/Dockerfile)  
  _Defines the NextCloud application Docker image._
- **Terraform**: Complete infrastructure setup in AWS ([terraform](terraform/))  
  _Handles AWS infrastructure setup for the NextCloud environment._

---

### Terraform Modules and Configuration

- **Variables**: [`terraform/terraform.tfvars`](terraform/terraform.tfvars)  
  _Configures all modules excluding security groups; for security groups see [modules/securitygroups/](modules/securitygroups/)._
- **Modules**:
  - **VPC**:
    - CIDR: `10.0.0.0/16`  
      _Main network address space._
    - Subnets:
      - `10.0.1.0/24`: Kubernetes control planes and nodes
      - `10.0.2.0/24`: Network Load Balancer, Classic Load Balancer
      - `10.0.3.0/24`: Controller EC2 instance
      - `10.0.4.0/24`: Bastion EC2 instance
      - `10.0.5.0/24`: Redis
      - `10.0.6.0/24` and `10.0.7.0/24`: RDS Instances
  - **EC2 Instances**:
    - **Bastion**:
      - Connects to the Controller  
        _Serves as an access point for secure SSH into the network._
      - **Ingress**: 22 TCP `[0.0.0.0/0]`
      - **Egress**: `[controller CIDR]`
    - **Controller**:
      - kOps cluster management with saved sensitive data ([controller.sh](terraform/scripts/controller.sh))  
        _Hosts kOps management and handles sensitive data. Contains scripts for setting up the cluster._
      - **Ingress**: 22 TCP `[bastion CIDR]`
      - **Egress**: `[0.0.0.0/0]`
  - **RDS**:
    - Database for NextCloud data  
      _Primary database for storing application data._
    - **Ingress**: 3306 TCP `[10.0.1.0/24]`
    - **Egress**: `[10.0.1.0/24]`
  - **Redis**:
    - Caching database for NextCloud  
      _Improves performance by caching data._
    - **Ingress**: 6379 TCP `[10.0.1.0/24]`
    - **Egress**: `[10.0.1.0/24]`
  - **S3 Buckets**:
    - **kOps State**: Stores state files for kOps management
    - **kOps OIDC**: Stores OIDC files for authentication configuration

