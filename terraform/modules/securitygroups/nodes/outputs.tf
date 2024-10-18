output "aws_securitygroup_nodes_sg_id" {
  description = "The ID of the nodes security group"
  value       = aws_security_group.nodes_sg.id
}
