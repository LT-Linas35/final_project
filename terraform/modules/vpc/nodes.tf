
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = var.vpc_name
  }
}

# Subnet in Availability Zone 1
resource "aws_subnet" "alb_subnet_az1" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "ALB Subnet AZ1"
    "kubernetes.io/cluster/k8s" = "shared"
    "kubernetes.io/role/elb"    = "1"
  }
}

# Subnet in Availability Zone 2
resource "aws_subnet" "alb_subnet_az2" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "eu-west-2c"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "ALB Subnet AZ2"
    "kubernetes.io/cluster/k8s" = "shared"
    "kubernetes.io/role/elb"    = "1"
  }
}


resource "aws_subnet" "nodes_vpc_sub" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.nodes_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.nodes_public_ip_on_launch
  tags = {
    Name = var.nodes_subnet_name
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/k8s" = "shared"
  }
}

resource "aws_subnet" "master_vpc_sub" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.master_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.masters_ip_on_launch
  tags = {
    Name = var.master_subnet_name
    "kubernetes.io/cluster/k8s" = "shared"
    "kubernetes.io/role/elb"    = "1"
  }
}


resource "aws_subnet" "controller_vpc_sub" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.controller_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.controller_ip_on_launch
  tags = {
    Name = var.controller_subnet_name

  }
}

resource "aws_subnet" "nginx_vpc_sub" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.nginx_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.nginx_ip_on_launch
  tags = {
    Name                        = var.nginx_subnet_name
    "kubernetes.io/cluster/k8s" = "shared"
    "kubernetes.io/role/elb"    = "1"  
  }
}


resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "nginx" {
  subnet_id      = aws_subnet.nginx_vpc_sub.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.nginx_vpc_sub.id

  tags = {
    Name = "my-nat-gateway"
  }
}

resource "aws_route_table" "private_route_table_with_nat" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "private-route-table-with-nat"
  }
}

resource "aws_route_table_association" "nodes_subnet_association_with_nat" {
  subnet_id      = aws_subnet.nodes_vpc_sub.id
  route_table_id = aws_route_table.private_route_table_with_nat.id
}

resource "aws_route_table_association" "master_subnet_association_with_nat" {
  subnet_id      = aws_subnet.master_vpc_sub.id
  route_table_id = aws_route_table.private_route_table_with_nat.id
}

resource "aws_route_table_association" "alb_subnet_az2" {
  subnet_id      = aws_subnet.alb_subnet_az2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "alb_subnet_az1" {
  subnet_id      = aws_subnet.alb_subnet_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "controller_subnet_association_with_nat" {
  subnet_id      = aws_subnet.controller_vpc_sub.id
  route_table_id = aws_route_table.public.id
}
