resource "aws_instance" "k8s-nodes" {
  count                  = var.k8s-node_count
  instance_type          = var.instance_type
  ami                    = var.ami
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.aws_securitygroup_web_sg_id]
  user_data              = data.template_file.user_data.rendered

  tags = {
    Name = "${var.instance_name}-${count.index + 1}"
  }
}

data "template_file" "user_data" {
  template = file("./scripts/nodes.sh")

  vars = {
    controller_hostname = var.controller_instance_private_hostname
  }
}
