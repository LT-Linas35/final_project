output "instance_private_ip" {
  value = tolist(aws_instance.k8s-nodes[*].private_ip)
}
