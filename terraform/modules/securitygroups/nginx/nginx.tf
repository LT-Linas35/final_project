resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Allow inbound SSH and HTTP"
  vpc_id      = var.master_k8s_vpc_id
/*
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
*/
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "10.0.3.0/24",
      "10.0.2.0/24",
      "10.0.1.0/24"
    ]
  }

  tags = {
    Name = "nginx-sg"
  }
}
