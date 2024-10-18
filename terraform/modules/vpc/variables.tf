variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
}

variable "nodes_subnet_cidr_block" {
  description = "CIDR block for the Subnet"
  type        = string
}

variable "nodes_subnet_name" {
  description = "Name for the Subnet"
  type        = string
}

variable "controller_subnet_name" {
  description = "Name for the controller"
  type        = string
}

variable "bastion_subnet_cidr_block" {
  description = "CIDR block for the bastion"
  type        = string
}

variable "bastion_subnet_name" {
  description = "Name for the Subnet"
  type        = string
}

variable "controller_subnet_cidr_block" {
  description = "CIDR block for the controller"
  type        = string
}

variable "master_subnet_cidr_block" {
  description = "CIDR block for the Subnet"
  type        = string
}

variable "master_subnet_name" {
  description = "Name for the Subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for the Subnet"
  type        = string
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
}

variable "bastion_ip_on_launch" {
  description = "Should be true if subnet is public"
  type        = bool
}

variable "controller_ip_on_launch" {
  description = "Should be true if subnet is public"
  type        = bool
}

variable "masters_ip_on_launch" {
  description = "Should be true if subnet is public"
  type        = bool
}

variable "nodes_public_ip_on_launch" {
  description = "Should be true if subnet is public"
  type        = bool
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

variable "alb_subnet_az1_cidr_block" {
  description = "The CIDR block for the ALB subnet in availability zone 1"
  type        = string
}

variable "alb_subnet_az1_availability_zone" {
  description = "The availability zone for the ALB subnet in availability zone 1"
  type        = string
}

variable "alb_subnet_az1_map_public_ip_on_launch" {
  description = "Whether to map public IP on launch for ALB subnet in availability zone 1"
  type        = bool
}

variable "alb_subnet_az2_map_public_ip_on_launch" {
  description = "Whether to map public IP on launch for ALB subnet in availability zone 1"
  type        = bool
}

variable "alb_subnet_az2_cidr_block" {
  description = "The CIDR block for the ALB subnet in availability zone 2"
  type        = string
}

variable "alb_subnet_az2_availability_zone" {
  description = "The availability zone for the ALB subnet in availability zone 2"
  type        = string
}

variable "alb1_alb_subnet_az1_name" {
  description = "The name for the ALB subnet in availability zone 1"
  type        = string
}

variable "alb2_alb_subnet_az2_name" {
  description = "The name for the ALB subnet in availability zone 2"
  type        = string
}

variable "public_nat_cidr_block" {
  description = "The CIDR block for the public route table NAT"
  type        = string
}

variable "priv_route_table_nat_cidr_block" {
  description = "The CIDR block for the private route table NAT"
  type        = string
}
