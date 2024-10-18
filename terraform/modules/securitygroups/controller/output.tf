output "aws_securitygroup_controller_sg_id" {
  description = "The ID of the controller security group"
  value       = aws_security_group.controller_sg.id
}
