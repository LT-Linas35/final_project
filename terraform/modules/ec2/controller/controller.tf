resource "aws_instance" "controller" {
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
    Name = var.instance_name
  }
}


data "template_file" "user_data" {
  template = file("./scripts/controller.sh")
}