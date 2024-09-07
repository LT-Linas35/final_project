output "instance_id" {
  value = aws_instance.master1.id
}

output "instance_public_ip" {
  value = aws_instance.master1.public_ip
}

output "instance_private_ip" {
  value = aws_instance.master1.private_ip
}