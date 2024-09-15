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


variable "nginx_subnet_cidr_block" {
  description = "CIDR block for the NGinx"
  type        = string
}

variable "nginx_subnet_name" {
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
  type        = bool
}

variable "enable_dns_hostnames" {
  type        = bool
}

variable "nginx_ip_on_launch" {
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

