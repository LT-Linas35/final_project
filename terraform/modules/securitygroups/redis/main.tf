resource "aws_security_group" "redis_sg" {
  name        = "redis security group"
  description = "Allow inbound traffic from local subnet"
  vpc_id      = var.aws_vpc_main

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.1.0/24"]
  }

  tags = {
    Name        = var.name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}
