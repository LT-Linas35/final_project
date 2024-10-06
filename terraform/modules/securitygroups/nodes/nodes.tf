resource "aws_security_group" "nodes_sg" {
  name        = "nodes-sg"
  description = "Allow inbound SSH and HTTP traffic and K8s"
  vpc_id      = var.nodes_k8s_vpc_id

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
    cidr_blocks = [
      "10.0.3.0/24"
    ]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.2.0/24",
      "10.0.1.0/24"
    ]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port   = 2375
    to_port     = 2376
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
    Name = "nodes-sg"
  }
}
