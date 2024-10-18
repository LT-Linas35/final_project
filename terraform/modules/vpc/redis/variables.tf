variable "aws_vpc_main" {
    type = string
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

variable "redis_ubnet_cidr_block" {
  description = "The CIDR block for the Redis subnet"
  type        = string
}

variable "name" {
  description = "The name for the Redis subnet"
  type        = string
}

variable "redis_subnet_group_name" {
  description = "The name of the Redis subnet group"
  type        = string
}

