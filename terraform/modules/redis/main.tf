resource "aws_elasticache_cluster" "redis" {
  cluster_id           = var.cluster_id
  engine               = var.engine
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name
  port                 = var.port
  subnet_group_name    = var.aws_elasticache_subnet_group_redis_subnet_group
  security_group_ids   = [var.aws_security_group_redis_sg]

  tags = {
    Name        = var.name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}
