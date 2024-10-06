resource "aws_instance" "nginx" {
  count                  = var.nginx_count
  instance_type          = var.instance_type
  ami                    = var.ami
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.aws_securitygroup_web_sg_id]
  user_data              = data.template_file.user_data.rendered

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  
  
  tags = {
    Name = "${var.instance_name}-${count.index + 1}"
  }
}

data "template_file" "user_data" {
  template = file("./scripts/nginx.sh")

  vars = {
    controller_hostname = var.controller_instance_private_hostname
  }
}
