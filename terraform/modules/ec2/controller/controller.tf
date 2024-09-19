resource "aws_instance" "controller" {
  instance_type          = var.instance_type
  ami                    = var.ami
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.aws_securitygroup_web_sg_id]
  user_data              = data.template_file.user_data.rendered
  iam_instance_profile = aws_iam_instance_profile.prometheus_node_profile.name
  
  root_block_device {
    volume_size = 4
    volume_type = "gp3"
  }

  tags = {
    Name = var.instance_name
  }
}


data "template_file" "user_data" {
  template = file("./scripts/controller.sh")
}


resource "aws_iam_instance_profile" "prometheus_node_profile" {
  name = "prometheus_node_profile"
  role = aws_iam_role.prometheus_node_role.name
}

resource "aws_iam_role" "prometheus_node_role" {
  name = "prometheus_node_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_readonly_policy" {
  name        = "ec2_readonly_policy"
  description = "Policy for Prometheus to discover EC2 instances"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeRegions"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.prometheus_node_role.name
  policy_arn = aws_iam_policy.ec2_readonly_policy.arn
}
