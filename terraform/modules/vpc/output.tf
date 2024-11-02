output "vpc_id" {
  description = "The ID of the main VPC for the Kubernetes infrastructure"
  value       = aws_vpc.k8s_vpc.id
}


output "controller_subnet_id" {
  description = "The ID of the subnet for the controller node"
  value       = aws_subnet.controller_vpc_sub.id
}

output "bastion_subnet_id" {
  description = "The ID of the subnet for the bastion host"
  value       = aws_subnet.bastion_vpc_sub.id
}

output "kops_subnet_id" {
  description = "The ID of the subnet for the Kops host"
  value       = aws_subnet.kops_vpc_sub.id
}

output "kops_nlb_subnet_id" {
  description = "The ID of the subnet for the Kops NLB host"
  value       = aws_subnet.kops_nlb_vpc_sub.id
}