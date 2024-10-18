output "redis_endpoint" {
  description = "The endpoint for the Redis cluster."
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "The Port for the Redis cluster."
  value       = aws_elasticache_cluster.redis.port
}
