variable "aws_securitygroup_nodes_sg_id" {
  description = "ID of the security group for the nodes servers"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the Nodes EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID for the Nodes EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the Nodes EC2 instance"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the Nodes EC2 instance"
  type        = string
}

variable "key_name" {
  description = "AWS Key Name"
  type        = string
}

variable "k8s-node_count" {
  description = "Kubernetes node count"
  type        = number
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
  description = "Nodes volume size"
  type        = string
}

variable "volume_type" {
  description = "Nodes volume type"
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

variable "controller_instance_id" {
  description = "ID of the controller instance"
  type        = string
}

variable "master_instance_id" {
  description = "ID of the master instance"
  type        = list(string)
}
