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
