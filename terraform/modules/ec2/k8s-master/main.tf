resource "aws_instance" "k8s-master" {
  count = var.k8s-master_count

  private_ip             = cidrhost(local.subnet_cidr, local.starting_ip + count.index)
  instance_type          = var.instance_type
  ami                    = var.ami
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.aws_securitygroup_master_sg_id]
  iam_instance_profile   = var.ec2_instance_profile_name
  user_data              = data.template_file.user_data.rendered

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  tags = {
    Name                        = "${var.instance_name}-${count.index + 1}"
    "kubernetes.io/cluster/k8s" = "shared"
    "kubernetes.io/role/elb"    = "1"
    Cluster                     = var.Cluster
    Environment                 = var.Environment
    ManagedBy                   = var.ManagedBy
  }
}

data "template_file" "user_data" {
  template = file("./scripts/master.sh")

  vars = {
    controller_hostname = var.controller_instance_private_hostname
    DATABASE_TYPE       = var.DATABASE_TYPE
    DATABASE_NAME       = var.DATABASE_NAME
    DATABASE_HOST       = var.DATABASE_HOST
    DATABASE_PORT       = var.DATABASE_PORT
    DATABASE_USER       = var.DATABASE_USER
    DATABASE_PASSWORD   = var.DATABASE_PASSWORD
    ADMIN_USER          = var.ADMIN_USER
    ADMIN_PASSWORD      = var.ADMIN_PASSWORD
    ADMIN_EMAIL         = var.ADMIN_EMAIL
    REDIS_HOST          = var.REDIS_HOST
    REDIS_PORT          = var.REDIS_PORT
    REDIS_TIMEOUT       = var.REDIS_TIMEOUT
    REDIS_DBINDEX       = var.REDIS_DBINDEX
    S3_BUCKET           = var.S3_BUCKET
    S3_REGION           = var.S3_REGION
  }
}


locals {
  subnet_cidr   = var.master_subnet_cidr_block
  starting_ip   = 4
  num_instances = var.k8s-master_count
}
