
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
    nginx_count             = string
  })
}

######################################################################
variable "controller" {
  description = "Configuration for controller instances"
  type = object({
    ami                     = string
    instance_name           = string
    instance_type           = string
    key_name                = string
    map_public_ip_on_launch = bool
  })
}

######################################################################
variable "k8s-master" {
  description = "Configuration for master k8s instances"
  type = object({
    ami                     = string
    instance_name           = string
    instance_type           = string
    key_name                = string
    map_public_ip_on_launch = bool
    k8s-master_count        = string
  })
}


######################################################################
variable "k8s-nodes" {
  description = "Configuration for node1 instance"
  type = object({
    ami                     = string
    instance_name           = string
    instance_type           = string
    key_name                = string
    map_public_ip_on_launch = bool
    k8s-node_count          = string
  })
}

######################################################################
variable "k8s_vpc" {
  description = "Configuration for VPC instances"
  type = object({
    vpc_cidr_block               = string
    vpc_name                     = string
    nginx_subnet_cidr_block      = string
    controller_subnet_cidr_block = string
    master_subnet_cidr_block     = string
    nodes_subnet_cidr_block      = string
    nginx_subnet_name            = string
    controller_subnet_name       = string
    master_subnet_name           = string
    nodes_subnet_name            = string
    availability_zone            = string
    enable_dns_hostnames         = bool
    enable_dns_support           = bool
  })
}
