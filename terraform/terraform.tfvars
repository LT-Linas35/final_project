# AWS region
aws_region = "eu-west-2"

CLUSTER_NAME = "k8s"

nginx = {
  ami                     = "ami-07d1e0a32156d0d21"
  instance_type           = "t2.micro"
  instance_name           = "nginx"
  key_name                = "Linas"
  map_public_ip_on_launch = true
  nginx_count             = "0"
}

controller = {
  ami                     = "ami-07d1e0a32156d0d21"
  instance_type           = "t3.small"
  instance_name           = "controller"
  key_name                = "Linas"
  map_public_ip_on_launch = true
}

k8s-master = {
  ami                     = "ami-07d1e0a32156d0d21"
  instance_type           = "t3.medium"
  instance_name           = "k8s-masters"
  key_name                = "Linas"
  map_public_ip_on_launch = true
  k8s-master_count        = "1"
}

# AWS EC2 NODES Variables
k8s-nodes = {
  ami                     = "ami-07d1e0a32156d0d21"
  instance_type           = "t3.medium"
  instance_name           = "k8s-nodes"
  key_name                = "Linas"
  map_public_ip_on_launch = true
  k8s-node_count          = "1"
}

# AWS VPC WEB
k8s_vpc = {
  vpc_cidr_block               = "10.0.0.0/16"
  vpc_name                     = "my-vpc"
  nginx_subnet_cidr_block      = "10.0.4.0/24"
  controller_subnet_cidr_block = "10.0.3.0/24"
  master_subnet_cidr_block     = "10.0.2.0/24"
  nodes_subnet_cidr_block      = "10.0.1.0/24"
  nginx_subnet_name            = "nginx-subnet"
  controller_subnet_name       = "controller-subnet"
  master_subnet_name           = "master-subnet"
  nodes_subnet_name            = "nodes-subnet"
  availability_zone            = "eu-west-2a"
  enable_dns_hostnames         = true
  enable_dns_support           = true
}
