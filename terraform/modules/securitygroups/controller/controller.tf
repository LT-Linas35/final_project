resource "aws_security_group" "controller_sg" {
  name        = "controller-sg"
  description = "Allow inbound SSH"
  vpc_id      = var.master_k8s_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.4.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "controller-sg"
  }
}
