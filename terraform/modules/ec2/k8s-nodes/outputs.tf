output "instance_private_ip" {
  description = "The private IP addresses of the Kubernetes nodes"
  value       = tolist(aws_instance.k8s-nodes[*].private_ip)
}
