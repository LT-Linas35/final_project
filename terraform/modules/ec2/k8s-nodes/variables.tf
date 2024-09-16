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

variable "k8s-node_count" {
  description = "Kubernetes node count"
  type        = number
}

variable "controller_instance_private_hostname" {
  description = "Controller IP address"
  type        = string
}