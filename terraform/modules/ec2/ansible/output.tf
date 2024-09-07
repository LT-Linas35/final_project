output "ansible_instance_private_ip" {
  value = aws_instance.ansible.private_ip
}