output "instance_id" {
  description = "The IDs of the Kubernetes master instances"
  value       = tolist(aws_instance.k8s-master[*].id)
}

output "instance_public_ip" {
  description = "The public IP addresses of the Kubernetes master instances"
  value       = tolist(aws_instance.k8s-master[*].public_ip)
}

output "instance_private_ip" {
  description = "The private IP addresses of the Kubernetes master instances"
  value       = tolist(aws_instance.k8s-master[*].private_ip)
}
