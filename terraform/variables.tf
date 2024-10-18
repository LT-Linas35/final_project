
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "cluster" {
  type = object({
    CLUSTER_NAME = string
    Environment  = string
    ManagedBy    = string
  })
}

######################################################################
variable "bastion" {
  description = "Configuration for bastion instances"
  type = object({
    ami                     = string
    instance_name           = string
    instance_type           = string
    key_name                = string
    map_public_ip_on_launch = bool
    bastion_count           = number
    volume_type             = string
    volume_size             = number
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
    volume_type             = string
    volume_size             = number
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
    k8s-master_count        = number
    volume_type             = string
    volume_size             = number
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
    k8s-node_count          = number
    volume_type             = string
    volume_size             = number
  })
}

######################################################################
variable "k8s_vpc" {
  description = "Configuration for VPC instances"
  type = object({
    vpc_cidr_block                         = string
    vpc_name                               = string
    bastion_subnet_cidr_block              = string
    controller_subnet_cidr_block           = string
    master_subnet_cidr_block               = string
    nodes_subnet_cidr_block                = string
    bastion_subnet_name                    = string
    controller_subnet_name                 = string
    master_subnet_name                     = string
    nodes_subnet_name                      = string
    availability_zone                      = string
    enable_dns_hostnames                   = bool
    enable_dns_support                     = bool
    public_nat_cidr_block                  = string
    priv_route_table_nat_cidr_block        = string
    alb1_alb_subnet_az1_name               = string
    alb_subnet_az1_cidr_block              = string
    alb_subnet_az1_availability_zone       = string
    alb_subnet_az1_map_public_ip_on_launch = bool
    alb2_alb_subnet_az2_name               = string
    alb_subnet_az2_cidr_block              = string
    alb_subnet_az2_availability_zone       = string
    alb_subnet_az2_map_public_ip_on_launch = bool
  })
}

variable "rds" {
  description = "Configuration for the RDS database instance."
  type = object({
    allocated_storage      = number
    db_name                = string
    engine                 = string
    engine_version         = string
    instance_class         = string
    username               = string
    password               = string
    parameter_group_name   = string
    skip_final_snapshot    = bool
    publicly_accessible    = bool
    rds1_cidr_block        = string
    rds1_availability_zone = string
    rds_name               = string
    rds2_cidr_block        = string
    rds2_availability_zone = string
    db_subnet_group_name   = string
  })
}

variable "redis" {
  description = "Configuration for the Redis cache cluster."
  type = object({
    cluster_id              = string
    engine                  = string
    node_type               = string
    num_cache_nodes         = number
    parameter_group_name    = string
    port                    = number
    redis_subnet_cidr_block = string
    name                    = string
    redis_subnet_group_name = string
  })
}

variable "nextcloud_install" {
  type = object({
    ADMIN_USER     = string
    ADMIN_PASSWORD = string
    ADMIN_EMAIL    = string
    REDIS_TIMEOUT  = number
    REDIS_DBINDEX  = number
    S3_BUCKET      = string
  })
}



