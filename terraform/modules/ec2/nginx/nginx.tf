resource "aws_instance" "nginx" {
  instance_type           = var.instance_type
  ami                     = var.ami
  key_name                = var.key_name
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [var.aws_securitygroup_web_sg_id]

  tags = {
    Name = var.instance_name
  }
}
