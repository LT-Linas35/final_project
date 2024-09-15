output "controller_instance_private_ip" {
  value = aws_instance.controller.host_id
}

output "controller_instance_private_hostname" {
  value = aws_instance.controller.private_dns
}