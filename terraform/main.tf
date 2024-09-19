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
}

module "masters_sg" {
  source            = "./modules/securitygroups/masters"
  master_k8s_vpc_id = module.vpc.vpc_id
}

module "nginx_sg" {
  source            = "./modules/securitygroups/nginx"
  master_k8s_vpc_id = module.vpc.vpc_id
}

module "controller_sg" {
  source            = "./modules/securitygroups/controller"
  master_k8s_vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source                       = "./modules/vpc/"
  availability_zone            = var.k8s_vpc.availability_zone
  nginx_subnet_cidr_block      = var.k8s_vpc.nginx_subnet_cidr_block
  nginx_subnet_name            = var.k8s_vpc.nginx_subnet_name
  controller_subnet_cidr_block = var.k8s_vpc.controller_subnet_cidr_block
  controller_subnet_name       = var.k8s_vpc.controller_subnet_name
  master_subnet_cidr_block     = var.k8s_vpc.master_subnet_cidr_block
  master_subnet_name           = var.k8s_vpc.master_subnet_name
  nodes_subnet_cidr_block      = var.k8s_vpc.nodes_subnet_cidr_block
  nodes_subnet_name            = var.k8s_vpc.nodes_subnet_name
  vpc_cidr_block               = var.k8s_vpc.vpc_cidr_block
  vpc_name                     = var.k8s_vpc.vpc_name
  enable_dns_hostnames         = var.k8s_vpc.enable_dns_hostnames
  enable_dns_support           = var.k8s_vpc.enable_dns_support
  nginx_ip_on_launch           = var.nginx.map_public_ip_on_launch
  controller_ip_on_launch      = var.controller.map_public_ip_on_launch
  masters_ip_on_launch         = var.k8s-master.map_public_ip_on_launch
  nodes_public_ip_on_launch    = var.k8s-nodes.map_public_ip_on_launch
}

module "nginx" {
  source                               = "./modules/ec2/nginx"
  ami                                  = var.nginx.ami
  aws_securitygroup_web_sg_id          = module.nginx_sg.aws_securitygroup_web_sg_id
  instance_name                        = var.nginx.instance_name
  key_name                             = var.nginx.key_name
  subnet_id                            = module.vpc.nginx_subnet_id
  nginx_count                          = var.nginx.nginx_count
  controller_instance_private_hostname = module.controller.controller_instance_private_hostname
}


module "k8s-master" {
  source                               = "./modules/ec2/k8s-master"
  subnet_id                            = module.vpc.masters_subnet_id
  ami                                  = var.k8s-master.ami
  instance_name                        = var.k8s-master.instance_name
  instance_type                        = var.k8s-master.instance_type
  key_name                             = var.k8s-master.key_name
  aws_securitygroup_web_sg_id          = module.masters_sg.aws_securitygroup_web_sg_id
  k8s-master_count                     = var.k8s-master.k8s-master_count
  master_subnet_cidr_block             = var.k8s_vpc.master_subnet_cidr_block
  controller_instance_private_hostname = module.controller.controller_instance_private_hostname
}


module "k8s-nodes" {
  source                               = "./modules/ec2/k8s-nodes"
  subnet_id                            = module.vpc.nodes_subnet_id
  ami                                  = var.k8s-nodes.ami
  instance_name                        = var.k8s-nodes.instance_name
  instance_type                        = var.k8s-nodes.instance_type
  key_name                             = var.k8s-nodes.key_name
  aws_securitygroup_web_sg_id          = module.nodes_sg.aws_securitygroup_web_sg_id
  k8s-node_count                       = var.k8s-nodes.k8s-node_count
  controller_instance_private_hostname = module.controller.controller_instance_private_hostname
}

module "controller" {
  source                      = "./modules/ec2/controller"
  ami                         = var.controller.ami
  aws_securitygroup_web_sg_id = module.controller_sg.aws_securitygroup_web_sg_id
  instance_name               = var.controller.instance_name
  key_name                    = var.controller.key_name
  subnet_id                   = module.vpc.controller_subnet_id
  //  k8s-master_instance_private_ip = module.k8s-master.instance_private_ip
  //  nginx_instance_private_ip      = module.nginx.instance_private_ip
  //  k8s-nodes_instance_private_ips = module.k8s-nodes.instance_private_ip
  instance_type = var.controller.instance_type
}
