NextCloud for Company X

This NextCloud deployment serves as a comprehensive file storage and collaboration platform for Company X, which has a large number of employees. The platform supports secure file storage, document management, real-time chat, and office file editing capabilities, facilitating seamless teamwork and productivity across the organization.

Project overview:

 NextCloud source code
   https://github.com/LT-Linas35/nextcloud_server branch dev
    github actions:
      on push dev: super-linter@v7.1.0 (https://github.com/LT-Linas35/nextcloud_server.github/workflows/super-linter.yml) 
                   sonarcloud-github-action@master (https://github.com/LT-Linas35/nextcloud_server/.github/workflows/Sonar-Cloud-Scanner.yml) 
                     need to set up secrets.SONAR_TOKEN
      on release:  Super Linter and Sonar Cloud Scanner Release and Trigger build Docker image workflow
                      super-linter@v7.1.0
                      sonarcloud-github-action@master
                        will send API call to LaC final_project to start build NextCloud Docker image
                        need to setup secrets.workflow_token and token from final_project
                        (https://github.com/LT-Linas35/nextcloud_server/Super-Linter-and-Sonar-Cloud-Scanner-Release.yaml will call .github/workflows/main.yml)

 LaC 
   https://github.com/LT-Linas35/final_project
     github actions:
       on push main: sonarcloud-github-action@master (.github/workflows/sonar-cloud.yml) need to setup secrets.SONAR_TOKEN
                     trivy-action@ (.github/workflows/trivy.yml)
       on dispatch:  terraform-apply@ (.github/workflows/terraform-apply.yml)
                     terrafrom-apply need to set up 2 main variables in terrafrom-apply.yml and one secret
                     for any help see terrafrom-apply@action
                          TF_CLOUD_ORGANIZATION: ""
                          TF_WORKSPACE: ""
                          secrets.TF_API_TOKEN
       on API call from nextcloud_server (or manualy dispach): CI pipeline with Trivy and Docker image publish (main.yml) 
                         
     helm-charts -> nextcloud-chart NextCloud helm chart
     server -> NextCloud Dockerfile
     terraform -> To build all infrastructure in to AWS

  Terraform
    terraform.tfvars -> All available variables from all modules (excluding security groups, for edit security groups -> terrafrom/modules/securitygroups/)
    Modules:
      VPC
        cdir: [10.0.0.0/16]
          subnets: 
                    [10.0.1.0/24] kubernetes subnet for control planes and nodes
                    [10.0.2.0/24] kOps subnet for Network Load Balancer, Clasic Load Balancer 
                    [10.0.3.0/24] controller EC2
                    [10.0.4.0/24] bastion EC2
                    [10.0.5.0/24] Redis 
                    [10.0.6.0/24] RDS 1
                    [10.0.7.0/24] RDS 2                    
      EC2
       1. bastion    -> Connect to controller
          Ingress 22 TCP [0.0.0.0/0] | Engress 0 -1 [controller cdir] 
       2. controller -> kOps will build cluster, saved all sensitive information, bulding proccess, kube/config etc.
          Ingress 22 TCP [bastion cidr] | Engress 0 -1 [0.0.0.0/0]
          
      RDS 
        Database for storing NextCloud data
          Ingress 3306 TCP ["10.0.1.0/24"] | Engress 0 -1 ["10.0.1.0/24"]
      Redis
        Memory chashing database for NextCloud
          Ingress 6379 TCP ["10.0.1.0/24"] | Engress 0 -1 ["10.0.1.0/24"]
      S3
        bukets:
          1. kOps store state files
          2. kOps store oidc files
   
