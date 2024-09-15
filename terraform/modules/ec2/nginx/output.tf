output "instance_private_ip" {
  value = tolist(aws_instance.nginx[*].private_ip)
}