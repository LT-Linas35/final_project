output "vpc_id" {
  description = "The ID of the main VPC for the Kubernetes infrastructure"
  value       = aws_vpc.k8s_vpc.id
}

output "nodes_subnet_id" {
  description = "The ID of the subnet for Kubernetes nodes"
  value       = aws_subnet.nodes_vpc_sub.id
}

output "masters_subnet_id" {
  description = "The ID of the subnet for Kubernetes master nodes"
  value       = aws_subnet.master_vpc_sub.id
}

output "controller_subnet_id" {
  description = "The ID of the subnet for the controller node"
  value       = aws_subnet.controller_vpc_sub.id
}

output "bastion_subnet_id" {
  description = "The ID of the subnet for the bastion host"
  value       = aws_subnet.bastion_vpc_sub.id
}