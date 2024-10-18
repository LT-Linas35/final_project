resource "aws_security_group" "controller_sg" {
  name        = "controller-sg"
  description = "Allow inbound SSH and 5000 for API"
  vpc_id      = var.master_k8s_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.4.0/24"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.3.0/24",
      "10.0.2.0/24",
      "10.0.1.0/24"
    ]
  }


  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.2.0/24",
      "10.0.1.0/24"
    ]
  }  



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "controller-sg"
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}
