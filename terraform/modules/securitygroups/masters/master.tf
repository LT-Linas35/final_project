resource "aws_security_group" "master_sg" {
  name        = "master-sg"
  description = "Allow inbound SSH"
  vpc_id      = var.master_k8s_vpc_id


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "10.0.3.0/24",
      "10.0.2.0/24",
      "10.0.1.0/24"
    ]
  }
/*

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24"]
  }


  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.2.0/24",
      "10.0.1.0/24"
    ]
  }


  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.3.0/24",
      "10.0.2.0/24",
      "10.0.1.0/24"
    ]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.2.0/24"
    ]
  }
  ingress {
    from_port   = 10250
    to_port     = 10252
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.2.0/24",
      "10.0.1.0/24"
    ]
  }

  ingress {
    from_port   = 10251
    to_port     = 10252
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.2.0/24"
    ]
  }

  ingress {
    from_port   = 10255
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.3.0/24",
      "10.0.2.0/24",
      "10.0.1.0/24"
    ]
  }


  ingress {
    from_port   = 5473
    to_port     = 5473
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.3.0/24",
      "10.0.2.0/24",
      "10.0.1.0/24"
    ]
  }
  */

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "master-sg"
  }
}
