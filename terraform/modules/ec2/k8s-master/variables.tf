variable "aws_securitygroup_master_sg_id" {
  description = "ID of the security group for the master server"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the master EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID for the master EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the master EC2 instance"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the mater EC2 instance"
  type        = string
}

variable "key_name" {
  description = "AWS Key Name"
  type        = string
}

variable "k8s-master_count" {
  description = "Kubernetes master count"
  type        = number
}

variable "master_subnet_cidr_block" {
  description = "Kubernetes master CIDR"
  type        = string
}

variable "controller_instance_private_hostname" {
  description = "Controller IP address"
  type        = string
}

variable "ec2_instance_profile_name" {
  description = "EC2 Instance profile name"
  type        = string
}

variable "volume_size" {
  description = "Masters volume size"
  type        = string
}

variable "volume_type" {
  description = "Masters volume type"
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

variable "S3_BUCKET" {
  description = "The S3 bucket used for Nextcloud storage"
  type        = string
}

variable "S3_REGION" {
  description = "The region of the S3 bucket used for Nextcloud storage"
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
