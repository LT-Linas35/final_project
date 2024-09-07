variable "aws_securitygroup_web_sg_id" {
  description = "ID of the security group for the web server"
  type        = string
}

variable "subnet_id" {
  description = "AMI ID for the WEB EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID for the WEB EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the WEB EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name tag for the WEB EC2 instance"
  type        = string
}

variable "key_name" {
  description = "AWS Key Name"
  type        = string
}

variable "master_instance_private_ip" {
  description = "Masters private IP"
  type        = string
}

variable "nginx_instance_private_ip" {
  description = "NGinx private IP"
  type        = string
}

variable "node1_instance_private_ips" {
  description = "Node1 private IP"
  type        = string
}

variable "node2_instance_private_ips" {
  description = "Node2 private IP"
  type        = string
}

