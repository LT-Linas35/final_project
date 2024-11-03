################# Need Kops to work properly #############################
resource "aws_iam_user" "kops_user" {
  name = "kops"
}

resource "aws_iam_group" "kops_group" {
  name = "kops"
}

resource "aws_iam_group_membership" "kops_user_to_group" {
  name  = "kops_user_membership"
  users = [aws_iam_user.kops_user.name]
  group = aws_iam_group.kops_group.name
}

resource "aws_iam_user_policy_attachment" "kops_user_policy" {
  for_each = toset([
    "AmazonEC2FullAccess",
    "AmazonRoute53FullAccess",
    "AmazonS3FullAccess",
    "IAMFullAccess",
    "AmazonVPCFullAccess",
    "AmazonSQSFullAccess",
    "AmazonEventBridgeFullAccess"
  ])

  user       = aws_iam_user.kops_user.name
  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
}

resource "aws_iam_access_key" "kops_access_key" {
  user = aws_iam_user.kops_user.name
}


################ Need for NextCloud to store data to S3 #######################

resource "aws_iam_user" "s3_user" {
  name = "nextcloud-s3-user"
}

resource "aws_iam_access_key" "s3_user_key" {
  user = aws_iam_user.s3_user.name
}

resource "aws_iam_user_policy" "s3_user_policy" {
  name = "s3-user-policy"
  user = aws_iam_user.s3_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.nextcloud_install.S3_BUCKET}",
          "arn:aws:s3:::${var.nextcloud_install.S3_BUCKET}/*"
        ]
      }
    ]
  })
}

