output "aws_securitygroup_master_sg_id" {
  description = "The ID of the master security group"
  value       = aws_security_group.master_sg.id
}