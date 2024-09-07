resource "aws_instance" "ansible" {
  instance_type          = var.instance_type
  ami                    = var.ami
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.aws_securitygroup_web_sg_id]
  user_data              = data.template_file.user_data.rendered

  tags = {
    Name = var.instance_name
  }
}

data "template_file" "user_data" {
  template = file("./scripts/ansible.sh")

  vars = {
    ec2_key     = var.ec2_key
    nginx_ips   = join("\n", split(",", var.nginx_instance_private_ip))
    masters_ips = join("\n", split(",", var.master_instance_private_ip))
    nodes1_ips  = join("\n", split(",", var.node1_instance_private_ips))
    nodes2_ips  = join("\n", split(",", var.node2_instance_private_ips))
  }
}