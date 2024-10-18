output "aws_elasticache_subnet_group_redis_subnet_group" {
  description = "The name of the ElastiCache subnet group for Redis"
  value       = aws_elasticache_subnet_group.redis_subnet_group.name
}
