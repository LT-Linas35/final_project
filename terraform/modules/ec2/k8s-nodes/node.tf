resource "aws_instance" "k8s-nodes" {
  count                   = var.k8s-node_count
  instance_type           = var.instance_type
  ami                     = var.ami
  key_name                = var.key_name
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [var.aws_securitygroup_web_sg_id]

  user_data = file("./scripts/nodes.sh")

  tags = {
    Name = "k8s-node-${count.index + 1}"
  }
}
