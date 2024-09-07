variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

######################################################################
variable "nginx" {
  description = "Configuration for NGinx instances"
  type = object({
    ami                     = string
    instance_name           = string
    instance_type           = string
    key_name                = string
    map_public_ip_on_launch = bool

  })
}

######################################################################
variable "ansible" {
  description = "Configuration for Ansible instances"
  type = object({
    ami                     = string
    instance_name           = string
    instance_type           = string
    key_name                = string
    map_public_ip_on_launch = bool

  })
}

######################################################################
variable "master1" {
  description = "Configuration for master k8s instances"
  type = object({
    ami                     = string
    instance_name           = string
    instance_type           = string
    key_name                = string
    map_public_ip_on_launch = bool

  })
}


######################################################################
variable "node1" {
  description = "Configuration for node1 instance"
  type = object({
    ami                     = string
    instance_name           = string
    instance_type           = string
    key_name                = string
    map_public_ip_on_launch = bool

  })
}

######################################################################
variable "node2" {
  description = "Configuration for node2 instance"
  type = object({
    ami                     = string
    instance_name           = string
    instance_type           = string
    key_name                = string
    map_public_ip_on_launch = bool

  })
}

######################################################################
variable "k8s_vpc" {
  description = "Configuration for VPC instances"
  type = object({
    vpc_cidr_block            = string
    vpc_name                  = string
    nginx_subnet_cidr_block   = string
    ansible_subnet_cidr_block = string
    master_subnet_cidr_block  = string
    nodes_subnet_cidr_block   = string
    nginx_subnet_name         = string
    ansible_subnet_name       = string
    master_subnet_name        = string
    nodes_subnet_name         = string
    availability_zone         = string
    enable_dns_hostnames      = bool
    enable_dns_support        = bool
  })
}


/*
variable "EC2_web_ami" {
  description = "AMI ID for the nodes instance"
  type        = string
}

variable "EC2_web_instance_name" {
  description = "Name tag for the nodes instance"
  type        = string
}

variable "EC2_web_instance_type" {
  description = "Instance type for the nodes instance"
  type        = string
}

variable "EC2_web_key_name" {
  description = "Key pair name for the nodes instance"
  type        = string
}
*/


/*
variable "EC2_web_vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "EC2_web_vpc_name" {
  description = "Name for the VPC"
  type        = string
}

variable "EC2_web_subnet_cidr_block" {
  description = "CIDR block for the Subnet"
  type        = string
}

variable "EC2_web_subnet_name" {
  description = "Name for the Subnet"
  type        = string
}

variable "EC2_web_availability_zone" {
  description = "Availability Zone for the Subnet"
  type        = string
}

variable "EC2_web_map_public_ip_on_launch" {
  description = "Should be true if subnet is public"
  type        = bool
  default     = true
}
*/