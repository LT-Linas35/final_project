variable "aws_vpc_main" {
  description = "The main VPC ID for the infrastructure"
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

variable "name" {
  description = "The name of the Redis SG"
  type        = string
}