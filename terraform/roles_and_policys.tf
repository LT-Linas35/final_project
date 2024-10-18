
############################################################################################
/*
resource "aws_iam_role_policy_attachment" "attach_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_instance_profile.master_instance_profile.role
}

resource "aws_iam_role_policy_attachment" "attach_eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_instance_profile.master_instance_profile.role
}

*/

resource "aws_iam_role" "eks_role" {
  name               = "EKS-Mater-Roles"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "master_instance_profile" {
  name = "master_instance_profile"
  role = aws_iam_role.eks_role.name
}






############################################################################################



resource "aws_iam_role_policy_attachment" "attach_EC2FullAccess_policy_to_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "attach_s3_full_access_to_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_instance_profile.node_instance_profile.role
}

/*
resource "aws_iam_role_policy_attachment" "attach_eks_worker_policy_to_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_instance_profile.node_instance_profile.role
}
*/

resource "aws_iam_role_policy_attachment" "attach_elb_policy_to_role" {
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  role       = aws_iam_role.node_role.name
}


resource "aws_iam_instance_profile" "node_instance_profile" {
  name = "node_instance_profile"
  role = aws_iam_role.node_role.name
}

resource "aws_iam_role" "node_role" {
  name               = "Nodes-Roles"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}