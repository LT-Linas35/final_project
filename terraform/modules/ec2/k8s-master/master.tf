resource "aws_instance" "k8s-master" {
  count                   = var.k8s-master_count
  instance_type           = var.instance_type
  ami                     = var.ami
  key_name                = var.key_name
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [var.aws_securitygroup_web_sg_id]

  user_data = file("./scripts/master.sh")

  tags = {
    Name = "k8s-master-${count.index + 1}"
  }
}
