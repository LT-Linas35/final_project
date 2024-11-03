resource "aws_s3_bucket" "kops_state" {
  bucket = var.kops_state_bucket_name
}

resource "aws_s3_bucket_public_access_block" "kops_state" {
  bucket                  = aws_s3_bucket.kops_state.bucket

  block_public_acls       = var.s3_bucket_public_access_block_kops_state_block_public_acls
  block_public_policy     = var.s3_bucket_public_access_block_kops_state_block_public_policy
  ignore_public_acls      = var.s3_bucket_public_access_block_kops_state_ignore_public_acls
  restrict_public_buckets = var.s3_bucket_public_access_block_kops_state_restrict_public_buckets
}


resource "aws_s3_bucket" "oidc_store" {
  bucket = var.kops_oidc_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "oidc_store" {
  bucket = aws_s3_bucket.oidc_store.id
  rule {
    object_ownership = var.s3_bucket_ownership_controls_oidc_store
  }
}

resource "aws_s3_bucket_public_access_block" "oidc_store_block" {
  bucket                  = aws_s3_bucket.oidc_store.id
  block_public_acls       = var.s3_bucket_public_access_oidc_store_block_block_public_acls
  ignore_public_acls      = var.s3_bucket_public_access_oidc_store_block_ignore_public_acls
  block_public_policy     = var.s3_bucket_public_access_oidc_store_block_block_public_policy
  restrict_public_buckets = var.s3_bucket_public_access_oidc_store_block_restrict_public_buckets
}

resource "aws_s3_bucket_acl" "oidc_store_acl" {
  bucket     = aws_s3_bucket.oidc_store.id
  acl        = var.s3_bucket_acl_oidc_store_acl
  depends_on = [aws_s3_bucket_public_access_block.oidc_store_block]
}
