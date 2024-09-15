output "vpc_id" {
  value = aws_vpc.k8s_vpc.id
}

output "nodes_subnet_id" {
  value = aws_subnet.nodes_vpc_sub.id
}

output "masters_subnet_id" {
  value = aws_subnet.master_vpc_sub.id
}

output "controller_subnet_id" {
  value = aws_subnet.controller_vpc_sub.id
}

output "nginx_subnet_id" {
  value = aws_subnet.nginx_vpc_sub.id
}
