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

module "nodes_sg" {
  source           = "./modules/securitygroups/nodes"
  nodes_k8s_vpc_id = module.vpc.vpc_id
  Cluster          = var.cluster.CLUSTER_NAME
  Environment      = var.cluster.Environment
  ManagedBy        = var.cluster.ManagedBy
}

module "masters_sg" {
  source            = "./modules/securitygroups/masters"
  master_k8s_vpc_id = module.vpc.vpc_id
  Cluster           = var.cluster.CLUSTER_NAME
  Environment       = var.cluster.Environment
  ManagedBy         = var.cluster.ManagedBy
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
  source                                 = "./modules/vpc/"
  availability_zone                      = var.k8s_vpc.availability_zone
  bastion_subnet_cidr_block              = var.k8s_vpc.bastion_subnet_cidr_block
  bastion_subnet_name                    = var.k8s_vpc.bastion_subnet_name
  controller_subnet_cidr_block           = var.k8s_vpc.controller_subnet_cidr_block
  controller_subnet_name                 = var.k8s_vpc.controller_subnet_name
  master_subnet_cidr_block               = var.k8s_vpc.master_subnet_cidr_block
  master_subnet_name                     = var.k8s_vpc.master_subnet_name
  nodes_subnet_cidr_block                = var.k8s_vpc.nodes_subnet_cidr_block
  nodes_subnet_name                      = var.k8s_vpc.nodes_subnet_name
  vpc_cidr_block                         = var.k8s_vpc.vpc_cidr_block
  vpc_name                               = var.k8s_vpc.vpc_name
  enable_dns_hostnames                   = var.k8s_vpc.enable_dns_hostnames
  enable_dns_support                     = var.k8s_vpc.enable_dns_support
  bastion_ip_on_launch                   = var.bastion.map_public_ip_on_launch
  controller_ip_on_launch                = var.controller.map_public_ip_on_launch
  masters_ip_on_launch                   = var.k8s-master.map_public_ip_on_launch
  nodes_public_ip_on_launch              = var.k8s-nodes.map_public_ip_on_launch
  Cluster                                = var.cluster.CLUSTER_NAME
  Environment                            = var.cluster.Environment
  ManagedBy                              = var.cluster.ManagedBy
  public_nat_cidr_block                  = var.k8s_vpc.public_nat_cidr_block
  priv_route_table_nat_cidr_block        = var.k8s_vpc.priv_route_table_nat_cidr_block
  alb1_alb_subnet_az1_name               = var.k8s_vpc.alb1_alb_subnet_az1_name
  alb_subnet_az1_cidr_block              = var.k8s_vpc.alb_subnet_az1_cidr_block
  alb_subnet_az1_availability_zone       = var.k8s_vpc.alb_subnet_az1_availability_zone
  alb_subnet_az1_map_public_ip_on_launch = var.k8s_vpc.alb_subnet_az1_map_public_ip_on_launch
  alb2_alb_subnet_az2_name               = var.k8s_vpc.alb2_alb_subnet_az2_name
  alb_subnet_az2_cidr_block              = var.k8s_vpc.alb_subnet_az2_cidr_block
  alb_subnet_az2_availability_zone       = var.k8s_vpc.alb_subnet_az2_availability_zone
  alb_subnet_az2_map_public_ip_on_launch = var.k8s_vpc.alb_subnet_az2_map_public_ip_on_launch
}

module "bastion" {
  source                               = "./modules/ec2/bastion"
  ami                                  = var.bastion.ami
  aws_securitygroup_bastion_sg_id      = module.bastion_sg.aws_securitygroup_bastion_sg_id
  instance_name                        = var.bastion.instance_name
  key_name                             = var.bastion.key_name
  subnet_id                            = module.vpc.bastion_subnet_id
  bastion_count                        = var.bastion.bastion_count
  controller_instance_private_hostname = module.controller.controller_instance_private_hostname
  volume_type                          = var.bastion.volume_type
  volume_size                          = var.bastion.volume_size
  instance_type                        = var.bastion.instance_type
  Cluster                              = var.cluster.CLUSTER_NAME
  Environment                          = var.cluster.Environment
  ManagedBy                            = var.cluster.ManagedBy
}


module "k8s-master" {
  source                               = "./modules/ec2/k8s-master"
  subnet_id                            = module.vpc.masters_subnet_id
  ami                                  = var.k8s-master.ami
  instance_name                        = var.k8s-master.instance_name
  instance_type                        = var.k8s-master.instance_type
  key_name                             = var.k8s-master.key_name
  aws_securitygroup_master_sg_id       = module.masters_sg.aws_securitygroup_master_sg_id
  k8s-master_count                     = var.k8s-master.k8s-master_count
  master_subnet_cidr_block             = var.k8s_vpc.master_subnet_cidr_block
  controller_instance_private_hostname = module.controller.controller_instance_private_hostname
  ec2_instance_profile_name            = aws_iam_instance_profile.master_instance_profile.name
  volume_type                          = var.k8s-master.volume_type
  volume_size                          = var.k8s-master.volume_size
  DATABASE_TYPE                        = var.rds.engine
  DATABASE_NAME                        = var.rds.db_name
  DATABASE_HOST                        = module.rds.rds_endpoint
  DATABASE_PORT                        = module.rds.rds_port
  DATABASE_USER                        = var.rds.username
  DATABASE_PASSWORD                    = var.rds.password
  ADMIN_USER                           = var.nextcloud_install.ADMIN_USER
  ADMIN_PASSWORD                       = var.nextcloud_install.ADMIN_PASSWORD
  ADMIN_EMAIL                          = var.nextcloud_install.ADMIN_EMAIL
  REDIS_HOST                           = module.redis.redis_endpoint
  REDIS_PORT                           = module.redis.redis_port
  REDIS_TIMEOUT                        = var.nextcloud_install.REDIS_TIMEOUT
  REDIS_DBINDEX                        = var.nextcloud_install.REDIS_DBINDEX
  S3_BUCKET                            = var.nextcloud_install.S3_BUCKET
  S3_REGION                            = var.aws_region
  Cluster                              = var.cluster.CLUSTER_NAME
  Environment                          = var.cluster.Environment
  ManagedBy                            = var.cluster.ManagedBy
}


module "k8s-nodes" {
  source                               = "./modules/ec2/k8s-nodes"
  subnet_id                            = module.vpc.nodes_subnet_id
  ami                                  = var.k8s-nodes.ami
  instance_name                        = var.k8s-nodes.instance_name
  instance_type                        = var.k8s-nodes.instance_type
  key_name                             = var.k8s-nodes.key_name
  aws_securitygroup_nodes_sg_id        = module.nodes_sg.aws_securitygroup_nodes_sg_id
  k8s-node_count                       = var.k8s-nodes.k8s-node_count
  controller_instance_private_hostname = module.controller.controller_instance_private_hostname
  ec2_instance_profile_name            = aws_iam_instance_profile.node_instance_profile.name
  volume_type                          = var.k8s-nodes.volume_type
  volume_size                          = var.k8s-nodes.volume_size
  Cluster                              = var.cluster.CLUSTER_NAME
  Environment                          = var.cluster.Environment
  ManagedBy                            = var.cluster.ManagedBy
  master_instance_id                   = module.k8s-master.instance_id
  controller_instance_id               = module.controller.controller_instance_id
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
  Cluster                            = var.cluster.CLUSTER_NAME
  Environment                        = var.cluster.Environment
  ManagedBy                          = var.cluster.ManagedBy
}

# RDS instance module
module "rds" {
  source               = "./modules/rds"
  db_subnet_group_name = module.vpc_rds.db_subnet_group_name //FIX IT !!!
  rds_sg               = module.rds_sg.rds_sg
  allocated_storage    = var.rds.allocated_storage
  db_name              = var.rds.db_name
  engine               = var.rds.engine
  engine_version       = var.rds.engine_version
  instance_class       = var.rds.instance_class
  username             = var.rds.username
  password             = var.rds.password
  parameter_group_name = var.rds.parameter_group_name
  skip_final_snapshot  = var.rds.skip_final_snapshot
  publicly_accessible  = var.rds.publicly_accessible
  Cluster              = var.cluster.CLUSTER_NAME
  Environment          = var.cluster.Environment
  ManagedBy            = var.cluster.ManagedBy
  Name                 = var.rds.rds_name
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
  source                 = "./modules/vpc/rds"
  aws_vpc_main_id        = module.vpc.vpc_id
  Cluster                = var.cluster.CLUSTER_NAME
  Environment            = var.cluster.Environment
  ManagedBy              = var.cluster.ManagedBy
  rds1_cidr_block        = var.rds.rds1_cidr_block
  rds1_availability_zone = var.rds.rds1_availability_zone
  rds_name               = var.rds.rds_name
  rds2_cidr_block        = var.rds.rds2_cidr_block
  rds2_availability_zone = var.rds.rds2_availability_zone
  db_subnet_group_name   = var.rds.db_subnet_group_name
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


