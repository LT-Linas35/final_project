output "rds_sg" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
}
