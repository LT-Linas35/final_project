variable "aws_securitygroup_web_sg_id" {
  description = "ID of the security group for the CONTROL server"
  type        = string
}

variable "subnet_id" {
  description = "AMI ID for the CONTROL EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID for the CONTROL EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the CONTROL EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name tag for the CONTROL EC2 instance"
  type        = string
}

variable "key_name" {
  description = "AWS Key Name"
  type        = string
}

