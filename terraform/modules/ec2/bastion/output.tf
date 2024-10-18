output "instance_private_ip" {
  description = "The private IP addresses of the bastion instance"
  value       = tolist(aws_instance.bastion[*].private_ip)
}
