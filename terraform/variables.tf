
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "cluster" {
  type = object({
    CLUSTER_NAME               = string
    Environment                = string
    ManagedBy                  = string
    kops_state_bucket_name     = string
    kops_oidc_bucket_name      = string
    kops_subnet_cidr_block     = string
    kops_subnet_name           = string
    kops_ip_on_launch          = bool
    NODE_SIZE                  = string
    NODE_COUNT                 = number
    CONTROL_PLANE_SIZE         = string
    CONTROL_PLANE_COUNT        = number
    kops_nlb_subnet_cidr_block = string
    kops_nlb_subnet_name       = string
    KOPS_TOPOLOGY              = string
    KOPS_NLB                   = string
  })
}

variable "canary" {
  type = object({
  canarySteps_0_setWeight     = number
  canarySteps_0_pauseDuration = string
  canarySteps_1_setWeight     = number
  canarySteps_1_pauseDuration = string
  canarySteps_2_setWeight     = number 
  })
}

variable "s3" {
  type = object({
    s3_bucket_ownership_controls_oidc_store                          = string
    s3_bucket_public_access_oidc_store_block_block_public_acls       = bool
    s3_bucket_public_access_oidc_store_block_ignore_public_acls      = bool
    s3_bucket_public_access_oidc_store_block_block_public_policy     = bool
    s3_bucket_public_access_oidc_store_block_restrict_public_buckets = bool
    s3_bucket_acl_oidc_store_acl                                     = string
  })
}

variable "newrelic" {
  type = object({
    newrelic_global_licenseKey = string
    KSM_IMAGE_VERSION          = string
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
    create_bastion          = number
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
variable "k8s_vpc" {
  description = "Configuration for VPC instances"
  type = object({
    vpc_cidr_block                                = string
    vpc_name                                      = string
    bastion_subnet_cidr_block                     = string
    controller_subnet_cidr_block                  = string
    bastion_subnet_name                           = string
    controller_subnet_name                        = string
    availability_zone                             = string
    enable_dns_hostnames                          = bool
    enable_dns_support                            = bool
    public_nat_cidr_block                         = string
    priv_route_table_nat_cidr_block               = string
    internet_gateway_nextcloud_igw_name           = string
    route_table_nextcloud_public_name             = string
    nat_gateway_nat_gateway_name                  = string
    route_table_private_route_table_with_nat_name = string
  })
}

variable "rds" {
  description = "Configuration for the RDS database instance."
  type = object({
    allocated_storage           = number
    db_name                     = string
    engine                      = string
    engine_version              = string
    instance_class              = string
    username                    = string
    password                    = string
    parameter_group_name        = string
    skip_final_snapshot         = bool
    publicly_accessible         = bool
    rds1_cidr_block             = string
    rds1_availability_zone      = string
    rds_name                    = string
    rds2_cidr_block             = string
    rds2_availability_zone      = string
    db_subnet_group_name        = string
    db_subnet_group_description = string
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
