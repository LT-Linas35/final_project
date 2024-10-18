
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name        = var.vpc_name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}

# Subnet in Availability Zone 1
resource "aws_subnet" "alb_subnet_az1" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.alb_subnet_az1_cidr_block
  availability_zone       = var.alb_subnet_az1_availability_zone
  map_public_ip_on_launch = var.alb_subnet_az1_map_public_ip_on_launch

  tags = {
    Name                        = var.alb1_alb_subnet_az1_name
    "kubernetes.io/cluster/k8s" = "shared"
    "kubernetes.io/role/elb"    = "1"
    Cluster                     = var.Cluster
    Environment                 = var.Environment
    ManagedBy                   = var.ManagedBy
  }
}

# Subnet in Availability Zone 2
resource "aws_subnet" "alb_subnet_az2" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.alb_subnet_az2_cidr_block
  availability_zone       = var.alb_subnet_az2_availability_zone
  map_public_ip_on_launch = var.alb_subnet_az2_map_public_ip_on_launch

  tags = {
    Name                        = var.alb2_alb_subnet_az2_name
    "kubernetes.io/cluster/k8s" = "shared"
    "kubernetes.io/role/elb"    = "1"
    Cluster                     = var.Cluster
    Environment                 = var.Environment
    ManagedBy                   = var.ManagedBy
  }
}


resource "aws_subnet" "nodes_vpc_sub" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.nodes_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.nodes_public_ip_on_launch

  tags = {
    Name                              = var.nodes_subnet_name
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/k8s"       = "shared"
    Cluster                           = var.Cluster
    Environment                       = var.Environment
    ManagedBy                         = var.ManagedBy
  }
}

resource "aws_subnet" "master_vpc_sub" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.master_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.masters_ip_on_launch
  tags = {
    Name                        = var.master_subnet_name
    "kubernetes.io/cluster/k8s" = "shared"
    "kubernetes.io/role/elb"    = "1"
    Cluster                     = var.Cluster
    Environment                 = var.Environment
    ManagedBy                   = var.ManagedBy
  }
}


resource "aws_subnet" "controller_vpc_sub" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.controller_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.controller_ip_on_launch

  tags = {
    Name        = var.controller_subnet_name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}

resource "aws_subnet" "bastion_vpc_sub" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.bastion_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.bastion_ip_on_launch

  tags = {
    Name                        = var.bastion_subnet_name
    "kubernetes.io/cluster/k8s" = "shared"
    "kubernetes.io/role/elb"    = "1"
    Cluster                     = var.Cluster
    Environment                 = var.Environment
    ManagedBy                   = var.ManagedBy
  }
}


resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name        = "my-igw"
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = var.public_nat_cidr_block
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name        = "public"
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}

resource "aws_route_table_association" "bastion" {
  subnet_id      = aws_subnet.bastion_vpc_sub.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat_eip" {
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.bastion_vpc_sub.id

  tags = {
    Name        = "my-nat-gateway"
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}

resource "aws_route_table" "private_route_table_with_nat" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block     = var.priv_route_table_nat_cidr_block
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name        = "private-route-table-with-nat"
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
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
