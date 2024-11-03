terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.1.0"
}

provider "aws" {
  region     = var.aws_region
}

module "bastion_sg" {
  source            = "./modules/securitygroups/bastion"
  master_k8s_vpc_id = module.vpc.vpc_id
  Cluster           = var.cluster.CLUSTER_NAME
  Environment       = var.cluster.Environment
  ManagedBy         = var.cluster.ManagedBy
}

module "controller_sg" {
  source            = "./modules/securitygroups/controller"
  master_k8s_vpc_id = module.vpc.vpc_id
  Cluster           = var.cluster.CLUSTER_NAME
  Environment       = var.cluster.Environment
  ManagedBy         = var.cluster.ManagedBy
}

module "redis_sg" {
  source       = "./modules/securitygroups/redis"
  aws_vpc_main = module.vpc.vpc_id
  Cluster      = var.cluster.CLUSTER_NAME
  Environment  = var.cluster.Environment
  ManagedBy    = var.cluster.ManagedBy
  name         = var.redis.name
}

module "rds_sg" {
  source          = "./modules/securitygroups/rds"
  aws_vpc_main_id = module.vpc.vpc_id
  Cluster         = var.cluster.CLUSTER_NAME
  Environment     = var.cluster.Environment
  ManagedBy       = var.cluster.ManagedBy
}


module "vpc" {
  source                                        = "./modules/vpc/"
  availability_zone                             = var.k8s_vpc.availability_zone
  bastion_subnet_cidr_block                     = var.k8s_vpc.bastion_subnet_cidr_block
  bastion_subnet_name                           = var.k8s_vpc.bastion_subnet_name
  controller_subnet_cidr_block                  = var.k8s_vpc.controller_subnet_cidr_block
  controller_subnet_name                        = var.k8s_vpc.controller_subnet_name
  vpc_cidr_block                                = var.k8s_vpc.vpc_cidr_block
  vpc_name                                      = var.k8s_vpc.vpc_name
  enable_dns_hostnames                          = var.k8s_vpc.enable_dns_hostnames
  enable_dns_support                            = var.k8s_vpc.enable_dns_support
  bastion_ip_on_launch                          = var.bastion.map_public_ip_on_launch
  controller_ip_on_launch                       = var.controller.map_public_ip_on_launch
  Cluster                                       = var.cluster.CLUSTER_NAME
  Environment                                   = var.cluster.Environment
  ManagedBy                                     = var.cluster.ManagedBy
  public_nat_cidr_block                         = var.k8s_vpc.public_nat_cidr_block
  priv_route_table_nat_cidr_block               = var.k8s_vpc.priv_route_table_nat_cidr_block
  kops_subnet_cidr_block                        = var.cluster.kops_subnet_cidr_block
  kops_subnet_name                              = var.cluster.kops_subnet_name
  kops_ip_on_launch                             = var.cluster.kops_ip_on_launch
  kops_nlb_subnet_cidr_block                    = var.cluster.kops_nlb_subnet_cidr_block
  kops_nlb_subnet_name                          = var.cluster.kops_nlb_subnet_name
  internet_gateway_nextcloud_igw_name           = var.k8s_vpc.internet_gateway_nextcloud_igw_name
  route_table_nextcloud_public_name             = var.k8s_vpc.route_table_nextcloud_public_name
  nat_gateway_nat_gateway_name                  = var.k8s_vpc.nat_gateway_nat_gateway_name
  route_table_private_route_table_with_nat_name = var.k8s_vpc.route_table_private_route_table_with_nat_name
}


# VPC subnet and configuration for Redis
module "vpc_redis" {
  source                  = "./modules/vpc/redis"
  aws_vpc_main            = module.vpc.vpc_id
  Cluster                 = var.cluster.CLUSTER_NAME
  Environment             = var.cluster.Environment
  ManagedBy               = var.cluster.ManagedBy
  redis_ubnet_cidr_block  = var.redis.redis_subnet_cidr_block
  name                    = var.redis.name
  redis_subnet_group_name = var.redis.redis_subnet_group_name
}

# VPC subnet and configuration for RDS
module "vpc_rds" {
  source                      = "./modules/vpc/rds"
  aws_vpc_main_id             = module.vpc.vpc_id
  Cluster                     = var.cluster.CLUSTER_NAME
  Environment                 = var.cluster.Environment
  ManagedBy                   = var.cluster.ManagedBy
  rds1_cidr_block             = var.rds.rds1_cidr_block
  rds1_availability_zone      = var.rds.rds1_availability_zone
  rds_name                    = var.rds.rds_name
  rds2_cidr_block             = var.rds.rds2_cidr_block
  rds2_availability_zone      = var.rds.rds2_availability_zone
  db_subnet_group_name        = var.rds.db_subnet_group_name
  db_subnet_group_description = var.rds.db_subnet_group_description
}

module "s3" {
  source                                                           = "./modules/s3"
  kops_state_bucket_name                                           = var.cluster.kops_state_bucket_name
  kops_oidc_bucket_name                                            = var.cluster.kops_oidc_bucket_name
  s3_bucket_ownership_controls_oidc_store                          = var.s3.s3_bucket_ownership_controls_oidc_store
  s3_bucket_public_access_oidc_store_block_block_public_acls       = var.s3.s3_bucket_public_access_oidc_store_block_block_public_acls
  s3_bucket_public_access_oidc_store_block_ignore_public_acls      = var.s3.s3_bucket_public_access_oidc_store_block_ignore_public_acls
  s3_bucket_public_access_oidc_store_block_block_public_policy     = var.s3.s3_bucket_public_access_oidc_store_block_block_public_policy
  s3_bucket_public_access_oidc_store_block_restrict_public_buckets = var.s3.s3_bucket_public_access_oidc_store_block_restrict_public_buckets
  s3_bucket_acl_oidc_store_acl                                     = var.s3.s3_bucket_acl_oidc_store_acl
  s3_bucket_public_access_block_kops_state_block_public_acls       = var.s3.s3_bucket_public_access_block_kops_state_block_public_acls
  s3_bucket_public_access_block_kops_state_block_public_policy     = var.s3.s3_bucket_public_access_block_kops_state_block_public_policy
  s3_bucket_public_access_block_kops_state_ignore_public_acls      = var.s3.s3_bucket_public_access_block_kops_state_ignore_public_acls
  s3_bucket_public_access_block_kops_state_restrict_public_buckets = var.s3.s3_bucket_public_access_block_kops_state_restrict_public_buckets
}

# Redis instance module (Elasticache)
module "redis" {
  source                                          = "./modules/redis"
  aws_elasticache_subnet_group_redis_subnet_group = module.vpc_redis.aws_elasticache_subnet_group_redis_subnet_group //FIX IT !!!
  aws_security_group_redis_sg                     = module.redis_sg.aws_security_group_redis_sg
  cluster_id                                      = var.redis.cluster_id
  engine                                          = var.redis.engine
  node_type                                       = var.redis.node_type
  num_cache_nodes                                 = var.redis.num_cache_nodes
  parameter_group_name                            = var.redis.parameter_group_name
  port                                            = var.redis.port
  Cluster                                         = var.cluster.CLUSTER_NAME
  Environment                                     = var.cluster.Environment
  ManagedBy                                       = var.cluster.ManagedBy
  name                                            = var.redis.name
}

module "controller" {
  source                             = "./modules/ec2/controller"
  ami                                = var.controller.ami
  aws_securitygroup_controller_sg_id = module.controller_sg.aws_securitygroup_controller_sg_id
  instance_name                      = var.controller.instance_name
  key_name                           = var.controller.key_name
  subnet_id                          = module.vpc.controller_subnet_id
  instance_type                      = var.controller.instance_type
  volume_type                        = var.controller.volume_type
  volume_size                        = var.controller.volume_size

  DATABASE_TYPE     = var.rds.engine
  DATABASE_NAME     = var.rds.db_name
  DATABASE_HOST     = module.rds.rds_endpoint
  DATABASE_PORT     = module.rds.rds_port
  DATABASE_USER     = var.RDS_USERNAME
  DATABASE_PASSWORD = var.RDS_PASSWORD

  ADMIN_USER     = var.ADMIN_USER
  ADMIN_PASSWORD = var.ADMIN_PASSWORD
  ADMIN_EMAIL    = var.ADMIN_EMAIL

  REDIS_HOST    = module.redis.redis_endpoint
  REDIS_PORT    = module.redis.redis_port
  REDIS_TIMEOUT = var.nextcloud_install.REDIS_TIMEOUT
  REDIS_DBINDEX = var.nextcloud_install.REDIS_DBINDEX

  S3_NEXTCLOUD_BUCKET = var.nextcloud_install.S3_BUCKET
  S3_NEXTCLOUD_REGION = var.aws_region

  KOPS_REGION                = var.aws_region
  VPC_ID                     = module.vpc.vpc_id
  KOPS_AWS_ACCESS_KEY_ID     = aws_iam_access_key.kops_access_key.id
  KOPS_AWS_SECRET_ACCESS_KEY = aws_iam_access_key.kops_access_key.secret
  kops_state_bucket_name     = var.cluster.kops_state_bucket_name
  kops_oidc_bucket_name      = var.cluster.kops_oidc_bucket_name
  kops_subnet_id             = module.vpc.kops_subnet_id
  kops_utility_subnet_id     = module.vpc.kops_nlb_subnet_id
  KOPS_TOPOLOGY              = var.cluster.KOPS_TOPOLOGY
  KOPS_NLB                   = var.cluster.KOPS_NLB
  NODE_SIZE                  = var.cluster.NODE_SIZE
  NODE_COUNT                 = var.cluster.NODE_COUNT
  CONTROL_PLANE_SIZE         = var.cluster.CONTROL_PLANE_SIZE
  CONTROL_PLANE_COUNT        = var.cluster.CONTROL_PLANE_COUNT

  S3_USER_KEY    = aws_iam_access_key.s3_user_key.id
  S3_USER_SECRET = aws_iam_access_key.s3_user_key.secret

  newrelic_global_licenseKey = var.newrelic_global_licenseKey
  KSM_IMAGE_VERSION          = var.newrelic.KSM_IMAGE_VERSION

  canarySteps_0_setWeight     = var.canary.canarySteps_0_setWeight
  canarySteps_0_pauseDuration = var.canary.canarySteps_0_pauseDuration
  canarySteps_1_setWeight     = var.canary.canarySteps_1_setWeight
  canarySteps_1_pauseDuration = var.canary.canarySteps_1_pauseDuration
  canarySteps_2_setWeight     = var.canary.canarySteps_2_setWeight
  ARGOCD_PASSWORD             = var.ARGOCD_PASSWORD

  Cluster     = var.cluster.CLUSTER_NAME
  Environment = var.cluster.Environment
  ManagedBy   = var.cluster.ManagedBy
}

module "bastion" {
  source                               = "./modules/ec2/bastion"
  ami                                  = var.bastion.ami
  aws_securitygroup_bastion_sg_id      = module.bastion_sg.aws_securitygroup_bastion_sg_id
  instance_name                        = var.bastion.instance_name
  key_name                             = var.bastion.key_name
  subnet_id                            = module.vpc.bastion_subnet_id
  create_bastion                       = var.create_bastion
  controller_instance_private_hostname = module.controller.controller_instance_private_hostname
  volume_type                          = var.bastion.volume_type
  volume_size                          = var.bastion.volume_size
  instance_type                        = var.bastion.instance_type
  Cluster                              = var.cluster.CLUSTER_NAME
  Environment                          = var.cluster.Environment
  ManagedBy                            = var.cluster.ManagedBy
}


# RDS instance module
module "rds" {
  source               = "./modules/rds"
  storage_encrypted    = var.rds.storage_encrypted
  db_subnet_group_name = module.vpc_rds.db_subnet_group_name //FIX IT !!!
  rds_sg               = module.rds_sg.rds_sg
  allocated_storage    = var.rds.allocated_storage
  db_name              = var.rds.db_name
  engine               = var.rds.engine
  engine_version       = var.rds.engine_version
  instance_class       = var.rds.instance_class
  username             = var.RDS_USERNAME
  password             = var.RDS_PASSWORD
  parameter_group_name = var.rds.parameter_group_name
  skip_final_snapshot  = var.rds.skip_final_snapshot
  publicly_accessible  = var.rds.publicly_accessible
  Cluster              = var.cluster.CLUSTER_NAME
  Environment          = var.cluster.Environment
  ManagedBy            = var.cluster.ManagedBy
  Name                 = var.rds.rds_name
}
