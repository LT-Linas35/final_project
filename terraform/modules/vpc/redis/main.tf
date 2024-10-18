resource "aws_subnet" "redis" {
  vpc_id     = var.aws_vpc_main
  cidr_block = var.redis_ubnet_cidr_block

  tags = {
    Name = var.name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = var.redis_subnet_group_name
  subnet_ids = [aws_subnet.redis.id]
}