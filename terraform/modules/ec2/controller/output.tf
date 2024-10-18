output "controller_instance_private_ip" {
  description = "The private IP address of the controller instance"
  value       = aws_instance.controller.host_id
}

output "controller_instance_private_hostname" {
  description = "The private DNS hostname of the controller instance"
  value       = aws_instance.controller.private_dns
}

output "controller_instance_id" {
  value = aws_instance.controller.id
}

