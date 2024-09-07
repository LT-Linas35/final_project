# AWS region
aws_region = "us-east-1"

nginx = {
  ami                     = "ami-0583d8c7a9c35822c"
  instance_type           = "t2.micro"
  instance_name           = "nginx"
  key_name                = "Linas"
  map_public_ip_on_launch = true
}

ansible = {
  ami                     = "ami-0583d8c7a9c35822c"
  instance_type           = "t2.micro"
  instance_name           = "ansible"
  key_name                = "Linas"
  map_public_ip_on_launch = true
}

master1 = {
  ami                     = "ami-0583d8c7a9c35822c"
  instance_type           = "t3.small"
  instance_name           = "master-k8s"
  key_name                = "Linas"
  map_public_ip_on_launch = true
}

# AWS EC2 NODE1 Variables
node1 = {
  ami                     = "ami-0583d8c7a9c35822c"
  instance_type           = "t3.small"
  instance_name           = "node1"
  key_name                = "Linas"
  map_public_ip_on_launch = false
}

# AWS EC2 NODE2 Variables
node2 = {
  ami                     = "ami-0583d8c7a9c35822c"
  instance_type           = "t3.small"
  instance_name           = "node2"
  key_name                = "Linas"
  map_public_ip_on_launch = false
}

# AWS VPC WEB
k8s_vpc = {
  vpc_cidr_block            = "10.0.0.0/16"
  vpc_name                  = "my-vpc"
  nginx_subnet_cidr_block   = "10.0.4.0/28"
  ansible_subnet_cidr_block = "10.0.3.0/28"
  master_subnet_cidr_block  = "10.0.2.0/28"
  nodes_subnet_cidr_block   = "10.0.1.0/28"
  nginx_subnet_name         = "nginx-subnet"
  ansible_subnet_name       = "master-subnet"
  master_subnet_name        = "master-subnet"
  nodes_subnet_name         = "nodes-subnet"
  availability_zone         = "us-east-1a"
  enable_dns_hostnames      = true
  enable_dns_support        = true
}
