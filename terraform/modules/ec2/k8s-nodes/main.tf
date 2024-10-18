resource "aws_instance" "k8s-nodes" {
  count                  = var.k8s-node_count
  instance_type          = var.instance_type
  ami                    = var.ami
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.aws_securitygroup_nodes_sg_id]
  user_data              = data.template_file.user_data.rendered
  iam_instance_profile   = var.ec2_instance_profile_name

  depends_on = [
    var.controller_instance_id,
    var.master_instance_id
  ]

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
  template = file("./scripts/nodes.sh")

  vars = {
    controller_hostname = var.controller_instance_private_hostname
  }
}
