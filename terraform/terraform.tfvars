# AWS region
aws_region = "us-east-1"

nginx = {
  ami                     = "ami-0583d8c7a9c35822c"
  instance_type           = "t2.micro"
  instance_name           = "nginx"
  key_name                = "Linas"
  map_public_ip_on_launch = true
  nginx_count             = "1"
}

controller = {
  ami                     = "ami-0583d8c7a9c35822c"
  instance_type           = "t3.small"
  instance_name           = "controller"
  key_name                = "Linas"
  map_public_ip_on_launch = false
}

k8s-master = {
  ami                     = "ami-0583d8c7a9c35822c"
  instance_type           = "t3.small"
  instance_name           = "k8s-masters"
  key_name                = "Linas"
  map_public_ip_on_launch = false
  k8s-master_count        = "2"
}

# AWS EC2 NODES Variables
k8s-nodes = {
  ami                     = "ami-0583d8c7a9c35822c"
  instance_type           = "t3.small"
  instance_name           = "k8s-nodes"
  key_name                = "Linas"
  map_public_ip_on_launch = false
  k8s-node_count          = "0"
}

# AWS VPC WEB
k8s_vpc = {
  vpc_cidr_block               = "10.0.0.0/16"
  vpc_name                     = "my-vpc"
  nginx_subnet_cidr_block      = "10.0.4.0/28"
  controller_subnet_cidr_block = "10.0.3.0/28"
  master_subnet_cidr_block     = "10.0.2.0/28"
  nodes_subnet_cidr_block      = "10.0.1.0/28"
  nginx_subnet_name            = "nginx-subnet"
  controller_subnet_name       = "controller-subnet"
  master_subnet_name           = "master-subnet"
  nodes_subnet_name            = "nodes-subnet"
  availability_zone            = "us-east-1a"
  enable_dns_hostnames         = true
  enable_dns_support           = true
}
