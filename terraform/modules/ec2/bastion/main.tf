resource "aws_instance" "bastion" {
  count                  = var.create_bastion ? 1 : 0
  instance_type          = var.instance_type
  ami                    = var.ami
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.aws_securitygroup_bastion_sg_id]

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  tags = {
    Name        = var.instance_name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}
