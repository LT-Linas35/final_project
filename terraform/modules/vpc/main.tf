
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


resource "aws_subnet" "kops_vpc_sub" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.kops_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.kops_ip_on_launch

  tags = {
    Name        = var.kops_subnet_name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}

resource "aws_subnet" "kops_nlb_vpc_sub" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.kops_nlb_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.controller_ip_on_launch

  tags = {
    Name        = var.kops_nlb_subnet_name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
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
    Name        = var.bastion_subnet_name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}


resource "aws_internet_gateway" "nextcloud_igw" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name        = var.internet_gateway_nextcloud_igw_name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}

resource "aws_route_table" "nextcloud_public" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = var.public_nat_cidr_block
    gateway_id = aws_internet_gateway.nextcloud_igw.id
  }

  tags = {
    Name        = var.route_table_nextcloud_public_name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}

resource "aws_route_table_association" "bastion" {
  subnet_id      = aws_subnet.bastion_vpc_sub.id
  route_table_id = aws_route_table.nextcloud_public.id
}


resource "aws_route_table_association" "kops" {
  subnet_id      = aws_subnet.kops_vpc_sub.id
  route_table_id = aws_route_table.private_route_table_with_nat.id
}

resource "aws_route_table_association" "kops_nlb" {
  subnet_id      = aws_subnet.kops_nlb_vpc_sub.id
  route_table_id = aws_route_table.nextcloud_public.id
}


resource "aws_eip" "nat_eip" {
  //  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.bastion_vpc_sub.id

  tags = {
    Name        = var.nat_gateway_nat_gateway_name
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
    Name        = var.route_table_private_route_table_with_nat_name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}

resource "aws_route_table_association" "controller_subnet_association_with_nat" {
  subnet_id      = aws_subnet.controller_vpc_sub.id
  route_table_id = aws_route_table.nextcloud_public.id
}
