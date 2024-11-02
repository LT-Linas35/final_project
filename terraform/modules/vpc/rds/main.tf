resource "aws_subnet" "rds1" {
  vpc_id            = var.aws_vpc_main_id
  cidr_block        = var.rds1_cidr_block
  availability_zone = var.rds1_availability_zone

  tags = {
    Name        = var.rds_name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}

resource "aws_subnet" "rds2" {
  vpc_id            = var.aws_vpc_main_id
  cidr_block        = var.rds2_cidr_block
  availability_zone = var.rds2_availability_zone

  tags = {
    Name        = var.rds_name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name        = var.db_subnet_group_name
  description = var.db_subnet_group_description
  subnet_ids  = [aws_subnet.rds1.id, aws_subnet.rds2.id]
}
