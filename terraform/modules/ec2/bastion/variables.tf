variable "aws_securitygroup_bastion_sg_id" {
  description = "ID of the security group for the bastion server"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the bastion EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID for the bastion EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the bastion EC2 instance"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the bastion EC2 instance"
  type        = string
}

variable "key_name" {
  description = "AWS Key Name"
  type        = string
}

variable "bastion_count" {
  description = "Bastion Proxy count"
  type        = number
}

variable "controller_instance_private_hostname" {
  description = "Controller IP address"
  type        = string
}

variable "volume_size" {
  description = "Bastion volume size"
  type        = string
}

variable "volume_type" {
  description = "Bastion volume type"
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
