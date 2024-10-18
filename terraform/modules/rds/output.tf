output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.nextcloud.endpoint
}

output "rds_port" {
  description = "RDS database port number"
  value       = aws_db_instance.nextcloud.port
}
