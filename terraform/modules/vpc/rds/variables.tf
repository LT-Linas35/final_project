variable "aws_vpc_main_id" {
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

variable "rds1_cidr_block" {
  description = "The CIDR block for the first RDS subnet"
  type        = string
}

variable "rds1_availability_zone" {
  description = "The availability zone for the first RDS subnet"
  type        = string
}

variable "rds_name" {
  description = "The name for the RDS subnets"
  type        = string
}

variable "rds2_cidr_block" {
  description = "The CIDR block for the second RDS subnet"
  type        = string
}

variable "rds2_availability_zone" {
  description = "The availability zone for the second RDS subnet"
  type        = string
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  type        = string
}