terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.1.0"
}

provider "aws" {
  region     = var.aws_region
}

module "nodes_sg" {
  source           = "./modules/securitygroups/nodes"
  nodes_k8s_vpc_id = module.vpc.vpc_id
}

module "masters_sg" {
  source            = "./modules/securitygroups/masters"
  master_k8s_vpc_id = module.vpc.vpc_id
}

module "nginx_sg" {
  source            = "./modules/securitygroups/nginx"
  master_k8s_vpc_id = module.vpc.vpc_id
}

module "controller_sg" {
  source            = "./modules/securitygroups/controller"
  master_k8s_vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source                       = "./modules/vpc/"
  availability_zone            = var.k8s_vpc.availability_zone
  nginx_subnet_cidr_block      = var.k8s_vpc.nginx_subnet_cidr_block
  nginx_subnet_name            = var.k8s_vpc.nginx_subnet_name
  controller_subnet_cidr_block = var.k8s_vpc.controller_subnet_cidr_block
  controller_subnet_name       = var.k8s_vpc.controller_subnet_name
  master_subnet_cidr_block     = var.k8s_vpc.master_subnet_cidr_block
  master_subnet_name           = var.k8s_vpc.master_subnet_name
  nodes_subnet_cidr_block      = var.k8s_vpc.nodes_subnet_cidr_block
  nodes_subnet_name            = var.k8s_vpc.nodes_subnet_name
  vpc_cidr_block               = var.k8s_vpc.vpc_cidr_block
  vpc_name                     = var.k8s_vpc.vpc_name
  enable_dns_hostnames         = var.k8s_vpc.enable_dns_hostnames
  enable_dns_support           = var.k8s_vpc.enable_dns_support
  nginx_ip_on_launch           = var.nginx.map_public_ip_on_launch
  controller_ip_on_launch      = var.controller.map_public_ip_on_launch
  masters_ip_on_launch         = var.k8s-master.map_public_ip_on_launch
  nodes_public_ip_on_launch    = var.k8s-nodes.map_public_ip_on_launch
}

module "nginx" {
  source                               = "./modules/ec2/nginx"
  ami                                  = var.nginx.ami
  aws_securitygroup_web_sg_id          = module.nginx_sg.aws_securitygroup_web_sg_id
  instance_name                        = var.nginx.instance_name
  key_name                             = var.nginx.key_name
  subnet_id                            = module.vpc.nginx_subnet_id
  nginx_count                          = var.nginx.nginx_count
  controller_instance_private_hostname = module.controller.controller_instance_private_hostname
}


module "k8s-master" {
  source                               = "./modules/ec2/k8s-master"
  subnet_id                            = module.vpc.masters_subnet_id
  ami                                  = var.k8s-master.ami
  instance_name                        = var.k8s-master.instance_name
  instance_type                        = var.k8s-master.instance_type
  key_name                             = var.k8s-master.key_name
  aws_securitygroup_web_sg_id          = module.masters_sg.aws_securitygroup_web_sg_id
  k8s-master_count                     = var.k8s-master.k8s-master_count
  master_subnet_cidr_block             = var.k8s_vpc.master_subnet_cidr_block
  controller_instance_private_hostname = module.controller.controller_instance_private_hostname
}


module "k8s-nodes" {
  source                               = "./modules/ec2/k8s-nodes"
  subnet_id                            = module.vpc.nodes_subnet_id
  ami                                  = var.k8s-nodes.ami
  instance_name                        = var.k8s-nodes.instance_name
  instance_type                        = var.k8s-nodes.instance_type
  key_name                             = var.k8s-nodes.key_name
  aws_securitygroup_web_sg_id          = module.nodes_sg.aws_securitygroup_web_sg_id
  k8s-node_count                       = var.k8s-nodes.k8s-node_count
  controller_instance_private_hostname = module.controller.controller_instance_private_hostname
  ec2_instance_profile_name            = aws_iam_instance_profile.node_instance_profile.name
}

module "controller" {
  source                      = "./modules/ec2/controller"
  ami                         = var.controller.ami
  aws_securitygroup_web_sg_id = module.controller_sg.aws_securitygroup_web_sg_id
  instance_name               = var.controller.instance_name
  key_name                    = var.controller.key_name
  subnet_id                   = module.vpc.controller_subnet_id
  instance_type               = var.controller.instance_type
}



resource "aws_iam_policy" "aws_load_balancer_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for AWS Load Balancer Controller to manage ALB"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "ec2:GetCoipPoolUsage",
                "ec2:DescribeCoipPools",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTrustStores",
                "elasticloadbalancing:DescribeListenerAttributes"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient",
                "acm:ListCertificates",
                "acm:DescribeCertificate",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "waf-regional:GetWebACL",
                "waf-regional:GetWebACLForResource",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "CreateSecurityGroup"
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DeleteRule"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:ModifyListenerAttributes"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "StringEquals": {
                    "elasticloadbalancing:CreateAction": [
                        "CreateTargetGroup",
                        "CreateLoadBalancer"
                    ]
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:SetWebAcl",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:ModifyRule"
            ],
            "Resource": "*"
        }
    ]
  })
}


resource "aws_iam_role" "node_role" {
  name = "KubernetesNodeRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_alb_policy_to_role" {
  role       = aws_iam_role.node_role.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller_policy.arn
}

resource "aws_iam_instance_profile" "node_instance_profile" {
  name = "NodeInstanceProfile"
  role = aws_iam_role.node_role.name
}

