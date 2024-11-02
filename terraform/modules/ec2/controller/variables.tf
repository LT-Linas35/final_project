variable "aws_securitygroup_controller_sg_id" {
  description = "ID of the security group for the controller server"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the controller EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID for the controller EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the controller EC2 instance"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the controller EC2 instance"
  type        = string
}

variable "key_name" {
  description = "AWS Key Name"
  type        = string
}

variable "volume_size" {
  description = "Controller volume size"
  type        = string
}

variable "volume_type" {
  description = "Controller Volume type"
  type        = string
}

variable "Cluster" {
  description = "The name of the Kubernetes cluster"
  type        = string
}

variable "Environment" {
  description = "The environment for the resources (e.g., Production, Development)"
  type        = string
}

variable "ManagedBy" {
  description = "The entity responsible for managing these resources"
  type        = string
}


variable "DATABASE_TYPE" {
  description = "The type of the database used by Nextcloud"
  type        = string
}

variable "DATABASE_NAME" {
  description = "The name of the Nextcloud database"
  type        = string
}

variable "DATABASE_HOST" {
  description = "The host address of the Nextcloud database"
  type        = string
}

variable "DATABASE_PORT" {
  description = "The port used to connect to the Nextcloud database"
  type        = number
}

variable "DATABASE_USER" {
  description = "The username for the Nextcloud database"
  type        = string
}

variable "DATABASE_PASSWORD" {
  description = "The password for the Nextcloud database"
  type        = string
  sensitive   = true
}

variable "ADMIN_USER" {
  description = "The admin username for Nextcloud"
  type        = string
}

variable "ADMIN_PASSWORD" {
  description = "The admin password for Nextcloud"
  type        = string
  sensitive   = true
}

variable "ADMIN_EMAIL" {
  description = "The admin email for Nextcloud"
  type        = string
}

variable "REDIS_HOST" {
  description = "The Redis host for Nextcloud"
  type        = string
}

variable "REDIS_PORT" {
  description = "The port used by Redis for Nextcloud"
  type        = number
}

variable "REDIS_TIMEOUT" {
  description = "The timeout value for Redis connection"
  type        = number
}

variable "REDIS_DBINDEX" {
  description = "The Redis database index used for Nextcloud"
  type        = number
}

variable "S3_NEXTCLOUD_BUCKET" {
  description = "The S3 bucket used for Nextcloud storage"
  type        = string
}

variable "S3_NEXTCLOUD_REGION" {
  description = "The region of the S3 bucket used for Nextcloud storage"
  type        = string
}

variable "VPC_ID" {
  description = "The main VPC ID for the infrastructure"
  type        = string
}


variable "kops_state_bucket_name" {
  description = "Bucket name for Kops state store"
  type        = string
}

variable "kops_oidc_bucket_name" {
  description = "Bucket name for Kops OIDC store"
  type        = string
}

variable "NODE_SIZE" {
  description = "Node instance type (e.g., t3.medium)"
  type        = string
}

variable "NODE_COUNT" {
  description = "Number of worker nodes"
  type        = number
}

variable "CONTROL_PLANE_SIZE" {
  description = "Control plane instance type (e.g., t3.medium)"
  type        = string
}

variable "CONTROL_PLANE_COUNT" {
  description = "Number of control plane nodes"
  type        = number
}


variable "newrelic_global_licenseKey" {
  description = "New Relic global license key"
  type        = string
}

variable "KSM_IMAGE_VERSION" {
  description = "Kube State Metrics (KSM) image version"
  type        = string
}

variable "kops_utility_subnet_id" {
  type        = string
  description = "KOPS utility subnet ID."
}

variable "KOPS_TOPOLOGY" {
  type        = string
  description = "KOPS cluster topology type."
}

variable "KOPS_NLB" {
  type        = string
  description = "KOPS Network Load Balancer setting."
}

variable "KOPS_REGION" {
  type        = string
  description = "AWS region for KOPS cluster."
}

variable "kops_subnet_id" {
  type        = string
  description = "KOPS subnet ID."
}

variable "KOPS_AWS_ACCESS_KEY_ID" {
  type        = string
  description = "AWS Access Key ID for KOPS."
  sensitive   = true
}

variable "KOPS_AWS_SECRET_ACCESS_KEY" {
  type        = string
  description = "AWS Secret Access Key for KOPS."
  sensitive   = true
}

variable "S3_USER_SECRET" {
  type        = string
  description = "The secret access key for the IAM user with S3 access"
  sensitive   = true
}

variable "S3_USER_KEY" {
  type        = string
  description = "The access key ID for the IAM user with S3 access"
}

variable "canarySteps_0_setWeight" {
  description = "Weight percentage for the first canary step."
  type        = number
}

variable "canarySteps_0_pauseDuration" {
  description = "Pause duration after the first canary step."
  type        = string
}

variable "canarySteps_1_setWeight" {
  description = "Weight percentage for the second canary step."
  type        = number
}

variable "canarySteps_1_pauseDuration" {
  description = "Pause duration after the second canary step."
  type        = string
}

variable "canarySteps_2_setWeight" {
  description = "Weight percentage for the final canary step to complete deployment."
  type        = number
}

