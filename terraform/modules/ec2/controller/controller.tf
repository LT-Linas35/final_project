resource "aws_instance" "controller" {
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
  template = file("./scripts/controller.sh")
}
//  vars = {
//    nginx_ips      = join("\n", var.nginx_instance_private_ip)
//    k8s_master_ips = join("\n", var.k8s-master_instance_private_ip)
//    k8s_nodes_ips  = join("\n", var.k8s-nodes_instance_private_ips)
//  }
//}
