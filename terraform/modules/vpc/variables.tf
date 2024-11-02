variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name for the NextCloud VPC"
  type        = string
}


variable "controller_subnet_name" {
  description = "Name for the controller"
  type        = string
}

variable "controller_subnet_cidr_block" {
  description = "CIDR block for the controller"
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

variable "kops_subnet_cidr_block" {
  description = "CIDR block for the kops"
  type        = string
}

variable "kops_subnet_name" {
  description = "Name for the Kops Subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for Kops the Subnet"
  type        = string
}

variable "kops_nlb_subnet_cidr_block" {
  description = "CIDR block for the Kops NLB"
  type        = string
}

variable "kops_nlb_subnet_name" {
  description = "Name for the Kops NLB Subnet"
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

variable "kops_ip_on_launch" {
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


variable "public_nat_cidr_block" {
  description = "The CIDR block for the public route table NAT"
  type        = string
}

variable "priv_route_table_nat_cidr_block" {
  description = "The CIDR block for the private route table NAT"
  type        = string
}

variable "internet_gateway_nextcloud_igw_name" {
  description = "The name of the Internet Gateway for Nextcloud."
  type        = string
}

variable "route_table_nextcloud_public_name" {
  description = "The name of the route table for the public Nextcloud subnet."
  type        = string
}

variable "nat_gateway_nat_gateway_name" {
  description = "The name of the NAT Gateway used in the Nextcloud configuration."
  type        = string
}

variable "route_table_private_route_table_with_nat_name" {
  description = "The name of the private route table with NAT configuration for Nextcloud subnets."
  type        = string
}
