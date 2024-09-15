output "instance_id" {
  value = tolist(aws_instance.k8s-master[*].id)
}


output "instance_public_ip" {
  value = tolist(aws_instance.k8s-master[*].public_ip)
}


output "instance_private_ip" {
  value = tolist(aws_instance.k8s-master[*].private_ip)
}