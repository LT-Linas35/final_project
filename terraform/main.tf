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

module "ansible_sg" {
  source            = "./modules/securitygroups/ansible"
  master_k8s_vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source                    = "./modules/vpc/"
  availability_zone         = var.k8s_vpc.availability_zone
  nginx_subnet_cidr_block   = var.k8s_vpc.nginx_subnet_cidr_block
  nginx_subnet_name         = var.k8s_vpc.nginx_subnet_name
  ansible_subnet_cidr_block = var.k8s_vpc.ansible_subnet_cidr_block
  ansible_subnet_name       = var.k8s_vpc.ansible_subnet_name
  master_subnet_cidr_block  = var.k8s_vpc.master_subnet_cidr_block
  master_subnet_name        = var.k8s_vpc.master_subnet_name
  nodes_subnet_cidr_block   = var.k8s_vpc.nodes_subnet_cidr_block
  nodes_subnet_name         = var.k8s_vpc.nodes_subnet_name
  vpc_cidr_block            = var.k8s_vpc.vpc_cidr_block
  vpc_name                  = var.k8s_vpc.vpc_name
  enable_dns_hostnames      = var.k8s_vpc.enable_dns_hostnames
  enable_dns_support        = var.k8s_vpc.enable_dns_support
  nginx_ip_on_launch        = var.nginx.map_public_ip_on_launch
  ansible_ip_on_launch      = var.ansible.map_public_ip_on_launch
  masters_ip_on_launch      = var.master1.map_public_ip_on_launch
  nodes_public_ip_on_launch = var.node1.map_public_ip_on_launch
}

module "nginx" {
  source                      = "./modules/ec2/nginx"
  ami                         = var.nginx.ami
  aws_securitygroup_web_sg_id = module.nginx_sg.aws_securitygroup_web_sg_id
  instance_name               = var.nginx.instance_name
  key_name                    = var.nginx.key_name
  subnet_id                   = module.vpc.nginx_subnet_id
}


module "master1" {
  source                      = "./modules/ec2/master1"
  subnet_id                   = module.vpc.masters_subnet_id
  ami                         = var.master1.ami
  instance_name               = var.master1.instance_name
  instance_type               = var.master1.instance_type
  key_name                    = var.master1.key_name
  aws_securitygroup_web_sg_id = module.masters_sg.aws_securitygroup_web_sg_id
}


module "node1" {
  source                      = "./modules/ec2/node1"
  subnet_id                   = module.vpc.nodes_subnet_id
  ami                         = var.node1.ami
  instance_name               = var.node1.instance_name
  instance_type               = var.node1.instance_type
  key_name                    = var.node1.key_name
  aws_securitygroup_web_sg_id = module.nodes_sg.aws_securitygroup_web_sg_id
}

module "node2" {
  source                      = "./modules/ec2/node2"
  subnet_id                   = module.vpc.nodes_subnet_id
  ami                         = var.node2.ami
  instance_name               = var.node2.instance_name
  instance_type               = var.node2.instance_type
  key_name                    = var.node2.key_name
  aws_securitygroup_web_sg_id = module.nodes_sg.aws_securitygroup_web_sg_id
}

module "ansible" {
  source                      = "./modules/ec2/ansible"
  ami                         = var.ansible.ami
  aws_securitygroup_web_sg_id = module.ansible_sg.aws_securitygroup_web_sg_id
  instance_name               = var.ansible.instance_name
  key_name                    = var.ansible.key_name
  subnet_id                   = module.vpc.ansible_subnet_id
  master_instance_private_ip  = module.master1.instance_private_ip
  nginx_instance_private_ip   = module.nginx.instance_private_ip
  node1_instance_private_ips  = module.node1.instance_private_ip
  node2_instance_private_ips  = module.node2.instance_private_ip
}
